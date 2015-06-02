require 'bundler/gem_tasks'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

$: << File.join(File.dirname(__FILE__),'lib')

include Rake::DSL

gemspec = eval(File.read('stitches.gemspec'))
Gem::PackageTask.new(gemspec) {}
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
