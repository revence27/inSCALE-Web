class DistrictsHavePasswords < ActiveRecord::Migration
  def up
    add_column :districts, :password, :text, :default => "#{rand(10)}defaultpass#{rand(10)}", :null => false
  end

  def down
    remove_column :districts, :password
  end
end
