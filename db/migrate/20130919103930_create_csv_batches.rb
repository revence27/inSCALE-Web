class CreateCsvBatches < ActiveRecord::Migration
  def change
    create_table :csv_batches do |t|
      t.text        :heading
      t.text        :filename
      t.text        :first_row
      t.timestamps
    end
  end
end
