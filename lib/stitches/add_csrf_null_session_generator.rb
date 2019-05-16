require 'rails/generators'

module Stitches
  class AddCsrfNullSessionGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.join(File.dirname(__FILE__),"generator_files")))

    desc "Fixes CSRF error on startup for a service created with an older version of stitches"
    def add_csrf_null_session
      inject_into_file "app/controllers/api/api_controller.rb", after: /^class.*$/ do
        <<~CODE
          #
          # API clients pass an API key instead of a CSRF token; Use
          # :null_session CSRF protection to avoid an auth error for these
          # clients.
          #
          protect_from_forgery with: :null_session
        CODE
      end
    end
  end
end
