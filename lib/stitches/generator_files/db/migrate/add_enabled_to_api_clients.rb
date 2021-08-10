class AddEnabledToApiClients < ActiveRecord::Migration<% if Rails::VERSION::MAJOR >= 5 %>[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]<% end %>
  def change
    add_column :api_clients, :enabled, :bool, null: false, default: true
    remove_index :api_clients, [:name ] # existing one would be unique
    add_index :api_clients, [:name ]
  end
end
