class CreateSupervisors < ActiveRecord::Migration
  def change
    create_table :supervisors do |t|
      t.text          :name
      t.text          :number
      t.timestamps
    end
  end
end
