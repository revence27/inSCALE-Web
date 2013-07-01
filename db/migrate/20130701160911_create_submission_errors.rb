class CreateSubmissionErrors < ActiveRecord::Migration
  def change
    create_table :submission_errors do |t|
      t.text          :pdu
      t.text          :message
      t.text          :backtrace
      t.text          :url
      t.timestamps
    end
  end
end
