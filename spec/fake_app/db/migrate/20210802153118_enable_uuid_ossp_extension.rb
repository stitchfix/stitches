
class EnableUuidOsspExtension < ActiveRecord::Migration[6.1]

  def change
    enable_extension 'uuid-ossp'
  end
end
