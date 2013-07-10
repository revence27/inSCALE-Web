class VhtWithAppInfo < ActiveRecord::Migration
  def up
    add_column :system_users, :client, :text
  end

  def down
    remove_column :system_users, :client
  end
end
