class CreatePendingPdus < ActiveRecord::Migration
  def change
    create_table :pending_pdus do |t|
      t.text          :payload
      t.text          :probable_code
      t.text          :pdu_uid, :unique => true, :null => false
      t.text          :submission_path
      t.timestamps
    end
  end
end
