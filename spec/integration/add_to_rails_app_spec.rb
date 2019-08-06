require "spec_helper"
require "fileutils"
require "open3"

RSpec.describe "Adding Stitches to a New Rails App", :integration do
  let(:work_dir) { Dir.mktmpdir }
  let(:rails_app_name) { "swamp-thing" }

  def run(command)
    stdout, stderr, stat = Bundler.with_clean_env { Open3.capture3({ 'BUNDLE_GEMFILE' => 'Gemfile' }, command) }
    success = stat.success? && stdout !~ /Could not find generator/im

    if ENV["DEBUG"] == 'true' || !success
      $stdout.puts stdout
      $stderr.puts stderr
    end
    unless success
      raise "'#{command}' failed"
    end
  end

  around(:each) do |example|
    rails_new = [
      "rails new #{rails_app_name}",
      "--skip-yarn",
      "--skip-git",
      "--skip-keeps",
      "--skip-action-mailer",
      "--skip-active-storage",
      "--skip-action-cable",
      "--skip-spring",
      "--skip-listen",
      "--skip-coffee",
      "--skip-javascript",
      "--skip-turbolinks",
      "--skip-bootsnap",
      "--no-rc",
      "--skip-bundle",
    ].join(" ")

    # Use this local version of stitches rather than the one on Rubygems
    gem_path = File.expand_path("../..", File.dirname(__FILE__))
    use_local_stitches = %{echo "gem 'stitches', path: '#{gem_path}'" >> Gemfile}

    FileUtils.chdir work_dir do
      run rails_new

      FileUtils.chdir rails_app_name do
        run use_local_stitches
        run "bundle install"
        run "gem install apitome responders rspec-rails rspec_api_documentation"
        example.run
      end
    end
  end

  it "works as described in the README" do
    run "bin/rails generate stitches:api"

    rails_root = Pathname(work_dir) / rails_app_name

    # Yuck!  So much duplication!  BUT: Rails app templates have a notoriously silent failure mode, so mostly
    # what this is doing is ensuring that the generator inserted stuff when asked and that the very basics of what happens 
    # during generation are there.  It's gross, and I'm sorry.
    #
    # It's also in one big block because making a new rails app and running the generator multiple times seems bad.
    aggregate_failures do
      expect(File.exist?(rails_root / "app" / "controllers" / "api" / "api_controller.rb")).to eq(true)
      expect(rails_root / "Gemfile").to contain_gem("apitome")
      expect(rails_root / "Gemfile").to contain_gem("responders")
      expect(rails_root / "Gemfile").to contain_gem("rspec_api_documentation")
      expect(rails_root / "Gemfile").to contain_gem("capybara")
      expect(rails_root / "config" / "routes.rb").to have_route(namespace: :api, module_scope: :v1, resource: 'ping')
      expect(rails_root / "config" / "routes.rb").to have_route(namespace: :api, module_scope: :v2, resource: 'ping')
      expect(rails_root / "config" / "routes.rb").to have_mounted_engine("Apitome::Engine")
      migrations = Dir["#{rails_root}/db/migrate/*.rb"].sort
      expect(migrations.size).to eq(2)
      expect(migrations[0]).to match(/\/\d+_enable_uuid_ossp_extension.rb/)
      expect(migrations[1]).to match(/\/\d+_create_api_clients.rb/)
      expect(File.read(rails_root / "spec" / "rails_helper.rb")).to include("config.include RSpec::Rails::RequestExampleGroup, type: :feature")
      expect(File.read(rails_root / "spec" / "rails_helper.rb")).to include("require 'stitches/spec'")
      expect(File.read(rails_root / "spec" / "rails_helper.rb")).to include("require 'rspec_api_documentation'")
      expect(File.read(rails_root / "config" / "initializers" / "apitome.rb")).to include("config.mount_at = nil")
      expect(File.read(rails_root / "config" / "initializers" / "apitome.rb")).to include("config.title = 'Service Documentation'")
      expect(File.read(rails_root / "app" / "controllers" / "api" / "api_controller.rb")).to include("rescue_from StandardError")
      expect(File.read(rails_root / "app" / "controllers" / "api" / "api_controller.rb")).to include("rescue_from ActiveRecord::RecordNotFound")
    end
  end

  it "inserts the deprecation module into ApiController" do
    run "bin/rails generate stitches:api"

    rails_root = Pathname(work_dir) / rails_app_name
    api_controller = rails_root / "app" / "controllers" / "api" / "api_controller.rb"

    api_controller_contents = File.read(api_controller).split(/\n/)
    File.open(api_controller,"w") do |file|
      api_controller_contents.each do |line|
        file.puts line unless line =~ /Stitches::Deprecation/
      end
    end

    run "bin/rails generate stitches:add_deprecation"

    lines =  File.read(api_controller).split(/\n/)
    include_line = lines.detect { |line|
      line =~ /^\s+include Stitches::Deprecation$/
    }

    expect(include_line).to_not be_nil,lines.inspect
  end

  it "inserts can update old configuration" do
    run "bin/rails generate stitches:api"

    rails_root = Pathname(work_dir) / rails_app_name
    initializer = rails_root / "config" / "initializers" / "stitches.rb"

    initializer_contents = File.read(initializer).split(/\n/)
    found_initializer = false
    File.open(initializer,"w") do |file|
      initializer_contents.each do |line|
        if line =~ /allowlist/
          line = line.gsub("allowlist","whitelist")
          found_initializer = true
        end
        file.puts line
      end
    end

    raise "Didn't find 'allowlist' in the initializer?!" if !found_initializer

    run "bin/rails generate stitches:update_configuration"

    lines =  File.read(initializer).split(/\n/)
    include_line = lines.detect { |line|
      line =~ /whitelist/
    }

    expect(include_line).to be_nil,lines.inspect
  end

  class RoutesFileAnalysis
    attr_reader :routes_file
    def initialize(routes_file, namespace: nil, module_scope: nil, resource: nil, mounted_engine: nil)
      @routes_file = File.read(routes_file).split(/\n/)
      @found_namespace = false
      @found_module = false
      @found_resource = false
      @found_engine = false
      @engine_mounted = false

      @routes_file.each do |line|
        if line =~ /namespace :#{namespace} do/
          @found_namespace = true
        end
        if @found_namespace && line =~ /^\s*scope module: :#{module_scope}, constraints: Stitches::ApiVersionConstraint/
          @found_module = true
        end
        if @found_module && line =~ /^\s*resource\s+['"]#{resource}["']/
          @found_resource = true
        end
        if line =~ /api_docs = Rack::Auth::Basic.new\(#{mounted_engine}/
          @found_engine = true
        end
        if @found_engine && line =~ /mount api_docs/
          @engine_mounted = true
        end
      end
    end

    def found_namespace?
      @found_namespace
    end

    def found_module?
      @found_module
    end

    def found_resource?
      @found_resource
    end

    def found_engine?
      @found_engine
    end

    def engine_mounted?
      @engine_mounted
    end
  end

  RSpec::Matchers.define :have_mounted_engine do |engine_name|
    match do |routes_file|
      analysis = RoutesFileAnalysis.new(routes_file, mounted_engine: engine_name)
      analysis.engine_mounted?
    end
    failure_message do |routes_file|
      analysis = RoutesFileAnalysis.new(routes_file, mounted_engine: engine_name)
      error = if analysis.found_engine?
                "Found engine #{engine_name}, but it's not mounted"
              else
                "Didn't find engine #{engine_name}"
              end

      error + "\n#{File.read(analysis.routes_file.join("\n"))}"
    end
  end

  RSpec::Matchers.define :have_route do |namespace:, module_scope:, resource:|
    match do |routes_file|
      analysis = RoutesFileAnalysis.new(routes_file, namespace: namespace, module_scope: module_scope, resource: resource)
      analysis.found_resource? && analysis.found_module? && analysis.found_namespace?
    end

    failure_message do |routes_file|
      analysis = RoutesFileAnalysis.new(routes_file, namespace: namespace, module_scope: module_scope, resource: resource)
      error = if analysis.found_namespace?
                if analysis.found_module?
                  "Could not find resource '#{resource}'"
                else
                  "Could not find module '#{scope_module}'"
                end
              else
                "Could not find namespace '#{namespace}'"
              end
      error + "\n#{File.read(analysis.routes_file.join("\n"))}"
    end
  end
  RSpec::Matchers.define :contain_gem do |gem_name|
    match do |gemfile|
      File.read(gemfile).split(/\n/).any? { |line|
        line =~ /^\s*gem [\"\']#{gem_name}[\"\']/
      }
    end
    failure_message do |gemfile|
      "#{gem_name} not found in #{gemfile}:\n#{File.read(gemfile)}"
    end
  end
end
