require 'rails/generators'

module Stitches
  class AddEnabledToApiClientsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root(File.expand_path(File.join(File.dirname(__FILE__),"generator_files")))

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    desc "Upgrade your api_clients table so it uses the `enabled` field"
    def update_api_clients_table
      migration_template "db/migrate/add_enabled_to_api_clients.rb", "db/migrate/add_enabled_to_api_clients.rb"
    end

  end
end
