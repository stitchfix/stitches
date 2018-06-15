require 'rails/generators'

module Stitches
  class AddDeprecationGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.join(File.dirname(__FILE__),"generator_files")))

    desc "Adds deprecation support to an app creates with an older version of stitches"
    def add_deprecation
      inject_into_file "app/controllers/api/api_controller.rb", after: /^class.*$/ do<<-CODE

  include Stitches::Deprecation
      CODE
      end
    end
  end
end
