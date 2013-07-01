class CreateMissedCodes < ActiveRecord::Migration
  def change
    create_table :missed_codes do |t|
      t.text        :pdu
      t.text        :url
      t.text        :tentative_code
      t.timestamps
    end
  end
end
