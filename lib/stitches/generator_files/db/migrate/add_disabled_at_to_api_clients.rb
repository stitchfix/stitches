<% if Rails::VERSION::MAJOR >= 5 %>
class AddEnabledToApiClients < ActiveRecord::Migration[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]
<% else %>
class AddEnabledToApiClients < ActiveRecord::Migration
<% end %>
  def change
    add_column :api_clients, :disabled_at, "timestamp with time zone", null: true
  end
end