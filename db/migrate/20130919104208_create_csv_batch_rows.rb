class CreateCsvBatchRows < ActiveRecord::Migration
  def change
    create_table :csv_batch_rows do |t|
      t.text        :row
      t.integer     :csv_batch_id
      t.timestamps
    end
  end
end
