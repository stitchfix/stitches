class AddDisabledAtToApiClients < ActiveRecord::Migration<% if Rails::VERSION::MAJOR >= 5 %>[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]<% end %>
  def change
    add_column :api_clients, :disabled_at, "timestamp with time zone", null: true
  end
end
