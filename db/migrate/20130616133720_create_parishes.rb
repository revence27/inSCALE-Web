class CreateParishes < ActiveRecord::Migration
  def change
    return
    create_table :parishes do |t|
      t.timestamps
    end
  end
end
