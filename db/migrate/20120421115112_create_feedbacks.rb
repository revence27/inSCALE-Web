class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.text          :message
      t.text          :number
      t.text          :sender
      t.timestamp     :sent_on, :default => nil, :null  => true
      t.timestamps
    end
  end
end
