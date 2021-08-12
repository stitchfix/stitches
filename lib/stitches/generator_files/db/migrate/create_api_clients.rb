class CreateApiClients < ActiveRecord::Migration<% if Rails::VERSION::MAJOR >= 5 %>[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]<% end %>
  def change
    create_table :api_clients do |t|
      t.string :name, null: false
      t.column :key, "uuid default uuid_generate_v4()", null: false
      t.column :enabled, :bool, null: false, default: true
      t.column :created_at, "timestamp with time zone default now()", null: false
      t.column :disabled_at, "timestamp with time zone", null: true
    end
    add_index :api_clients, [:name]
    add_index :api_clients, [:key], unique: true
  end
end
