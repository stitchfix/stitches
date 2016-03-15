class CreateApiClients < ActiveRecord::Migration
  def change
    add_column :api_clients, :active, :boolean, default: true, null: false
  end
end
