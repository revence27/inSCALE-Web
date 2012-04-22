class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text        :pdu
      t.text        :number
      t.timestamp   :actual_time
      t.integer     :system_user_id
      t.timestamps
    end
  end
end
