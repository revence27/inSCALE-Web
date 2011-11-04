class LinkSubmissionsToUsers < ActiveRecord::Migration
  def up
    remove_column :submissions, :number
    add_column :submissions, :system_user_id, :integer
  end

  def down
    add_column :submissions, :number, :text
    remove_column :submissions, :system_user_id
  end
end
