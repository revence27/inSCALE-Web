class DownloadsAreContinuations < ActiveRecord::Migration
  def up
    add_column :csv_batches, :url, :text
    add_column :csv_batches, :point, :integer
  end

  def down
    remove_column :csv_batches, :url
    remove_column :csv_batches, :point
  end
end
