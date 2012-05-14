class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.text          :name
      t.text          :description
      t.text          :code
      t.timestamps
    end
  end
end
