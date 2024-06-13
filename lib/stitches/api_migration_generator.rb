require 'rails/generators'

module Stitches
  class ApiMigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root(File.expand_path(File.join(File.dirname(__FILE__), "generator_files")))

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    desc "Add a DB backed key storage system for your API service"
    def bootstrap_api_migration
      copy_file "app/models/api_client.rb"
      copy_file "lib/tasks/generate_api_key.rake"

      migration_template "db/migrate/enable_uuid_ossp_extension.rb", "db/migrate/enable_uuid_ossp_extension.rb"
      sleep 1 # allow clock to tick so we get different numbers
      migration_template "db/migrate/create_api_clients.rb", "db/migrate/create_api_clients.rb"
    end
  end
end
