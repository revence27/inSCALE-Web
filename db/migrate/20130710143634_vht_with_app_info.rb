class VhtWithAppInfo < ActiveRecord::Migration
  def up
    add_column :system_users, :latest_client, :text
  end

  def down
    remove_column :system_users, :latest_client
  end
end
