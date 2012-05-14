class AppsHavePublishers < ActiveRecord::Migration
  def up
    add_column :applications, :publisher_id, :integer
  end

  def down
    remove_column :applications, :publisher_id, :integer
  end
end
