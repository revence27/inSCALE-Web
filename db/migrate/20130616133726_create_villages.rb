class CreateVillages < ActiveRecord::Migration
  def change
    return
    create_table :villages do |t|
      t.timestamps
    end
  end
end
