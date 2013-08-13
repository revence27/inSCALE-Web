class DistrictAddresses < ActiveRecord::Migration
  def up
    add_column :districts, :email, :text
  end

  def down
    remove_column :districts, :email
  end
end
