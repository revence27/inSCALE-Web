class CreateMotivationalMessages < ActiveRecord::Migration
  def change
    create_table :motivational_messages do |t|
      t.integer :month
      t.text    :english

      t.timestamps
    end
  end
end
