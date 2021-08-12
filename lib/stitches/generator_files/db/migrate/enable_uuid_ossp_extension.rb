class EnableUuidOsspExtension < ActiveRecord::Migration<% if Rails::VERSION::MAJOR >= 5 %>[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]<% end %>
  def change
    enable_extension 'uuid-ossp'
  end
end
