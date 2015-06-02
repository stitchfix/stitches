class CreateApiClients < ActiveRecord::Migration
  def change
    create_table :api_clients do |t|
      t.string :name, null: false
      t.column :key, "uuid default uuid_generate_v4()", null: false
      t.column :created_at, "timestamp with time zone default now()", null: false
    end
    add_index :api_clients, [:name], unique: true
    add_index :api_clients, [:key], unique: true
  end
end
