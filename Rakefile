require 'bundler/gem_tasks'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'stitch_fix/y/tasks'

$: << File.join(File.dirname(__FILE__),'lib')

include Rake::DSL

gemspec = eval(File.read('stitches.gemspec'))
Gem::PackageTask.new(gemspec) {}
RSpec::Core::RakeTask.new(:spec)

StitchFix::Y::ReleaseTask.for_rubygems(gemspec)
StitchFix::Y::VersionTask.for_rubygems(gemspec)

task :default => :spec
