class AddEnabledToApiClients < ActiveRecord::Migration
  def change
    add_column :api_clients, :enabled, :bool, null: false, default: true
    remove_index :api_clients, [:name ] # existing one would be unique
    add_index :api_clients, [:name ]
  end
end
