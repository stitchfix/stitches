<% if Rails::VERSION::MAJOR >= 5 %>
class EnableUuidOsspExtension < ActiveRecord::Migration[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]
<% else %>
class EnableUuidOsspExtension < ActiveRecord::Migration
<% end %>
  def change
    enable_extension 'uuid-ossp'
  end
end
