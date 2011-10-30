class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text        :pdu
      t.text        :number
      t.timestamps
    end
  end
end
