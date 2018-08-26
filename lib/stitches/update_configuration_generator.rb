require 'rails/generators'

module Stitches
  class UpdateConfigurationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root(File.expand_path(File.join(File.dirname(__FILE__),"generator_files")))

    desc "Change your configuration to use 'allowlist' so you'll be ready for 4.x"
    def update_to_allowlist
      gsub_file "config/initializers/stitches.rb", /whitelist/, "allowlist"
      puts "🎉 You are now good to go!"
    end

  end
end
