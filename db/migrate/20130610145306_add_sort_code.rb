class AddSortCode < ActiveRecord::Migration
  def up
    add_column :system_users, :sort_code, :integer, :default => 0, :null => false
    SystemUser.all.each do |su|
      su.sort_code = su.code.to_i || 0
      su.save
    end
  end

  def down
    remove_column :system_users, :sort_code
  end
end
