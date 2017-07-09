<% if Rails::VERSION::MAJOR >= 5 %>
class AddEnabledToApiClients < ActiveRecord::Migration[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]
<% else %>
class AddEnabledToApiClients < ActiveRecord::Migration
<% end %>
  def change
    add_column :api_clients, :enabled, :bool, null: false, default: true
    remove_index :api_clients, [:name ] # existing one would be unique
    add_index :api_clients, [:name ]
  end
end
