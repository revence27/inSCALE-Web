class WithDates < ActiveRecord::Migration
  def up
    add_column :collected_infos, :start_date, :timestamp
    add_column :collected_infos, :end_date,   :timestamp
  end

  def down
    remove_column :collected_infos, :start_date
    remove_column :collected_infos, :end_date
  end
end
