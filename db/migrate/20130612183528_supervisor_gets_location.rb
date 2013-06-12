class SupervisorGetsLocation < ActiveRecord::Migration
  def up
    create_table :locations do |td|
      td.float    :xcoord
      td.float    :ycoord
      td.text     :name
    end
    add_column :supervisors, :location_id, :integer
  end

  def down
    drop_table :locations
    remove_column :supervisors, :location_id
  end
end
