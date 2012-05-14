class CreatePublishers < ActiveRecord::Migration
  def change
    create_table :publishers do |t|
      t.text        :name
      t.text        :address
      t.timestamps
    end
  end
end
