require 'rails/generators'

module Stitches
  class ApiGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root(File.expand_path(File.join(File.dirname(__FILE__),"generator_files")))

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    desc "Bootstraps your API service with a basic ping controller and spec to ensure everything is setup properly"
    def bootstrap_api
      inject_into_file "Gemfile", after: /^gem ["']pg['"].*$/ do<<-GEM

gem "apitome"
gem "responders"
      GEM
      end
      inject_into_file "config/routes.rb", before: /^end/ do<<-ROUTES
namespace :api do
  scope module: :v1, constraints: Stitches::ApiVersionConstraint.new(1) do
    resource 'ping', only: [ :create ]
    # Add your V1 resources here
  end
  scope module: :v2, constraints: Stitches::ApiVersionConstraint.new(2) do
    resource 'ping', only: [ :create ]
    # This is here simply to validate that versioning is working
    # as well as for your client to be able to validate this as well.
  end
end
api_docs = Rack::Auth::Basic.new(Apitome::Engine ) do |_,password|
  password == ENV['HTTP_AUTH_PASSWORD']
end
mount api_docs, at: "docs"
      ROUTES
      end

      run 'bundle install'

      copy_file "app/controllers/api.rb"
      copy_file "app/controllers/api/api_controller.rb"
      copy_file "app/controllers/api/v1.rb"
      copy_file "app/controllers/api/v2.rb"
      copy_file "app/controllers/api/v1/pings_controller.rb"
      copy_file "app/controllers/api/v2/pings_controller.rb"
      copy_file "app/models/api_client.rb"
      copy_file "config/initializers/stitches.rb"
      copy_file "lib/tasks/generate_api_key.rake"
      template "spec/features/api_spec.rb.erb", "spec/features/api_spec.rb"
      copy_file "spec/acceptance/ping_v1_spec.rb", "spec/acceptance/ping_v1_spec.rb"

      inject_into_file "Gemfile", after: /^group :test, :development do.*$/ do<<-GEM

  gem "rspec_api_documentation"
  gem "capybara"
      GEM
      end
      run 'bundle install'

      migration_template "db/migrate/enable_uuid_ossp_extension.rb", "db/migrate/enable_uuid_ossp_extension.rb"
      sleep 1 # allow clock to tick so we get different numbers
      migration_template "db/migrate/create_api_clients.rb", "db/migrate/create_api_clients.rb"

      inject_into_file 'spec/rails_helper.rb', %q{
config.include RSpec::Rails::RequestExampleGroup, type: :feature
}, before: /^end/

      inject_into_file 'spec/rails_helper.rb', before: /^RSpec.configure/ do<<-REQUIRE
require 'stitches/spec'
      REQUIRE
      end

      append_to_file 'spec/rails_helper.rb' do<<-RSPEC_API
require 'rspec_api_documentation'
RspecApiDocumentation.configure do |config|
config.format = :json
config.request_headers_to_include = %w(
  Accept
  Content-Type
  Authorization
  If-Modified-Since
)
config.response_headers_to_include = %w(
  Last-Modified
  ETag
)
config.api_name = "YOUR SERVICE NAME HERE"
end
      RSPEC_API
      end
      run "rails g apitome:install"
      gsub_file 'config/initializers/apitome.rb', /config.mount_at = .*$/, "config.mount_at = nil"
      gsub_file 'config/initializers/apitome.rb', /config.title = .*$/, "config.title = 'Service Documentation'"

    end
  end
end
