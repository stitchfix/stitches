require 'rails/generators'

module Stitches
  class AddDisabledAtToApiClientsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root(File.expand_path(File.join(File.dirname(__FILE__),"generator_files")))

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    desc "Upgrade your api_clients table so it includes the `disabled_at` field"
    def update_api_clients_table
      migration_template "db/migrate/add_disabled_at_to_api_clients.rb", "db/migrate/add_disabled_at_to_api_clients.rb"
    end
  end
end
