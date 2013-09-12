class LastContributionTime < ActiveRecord::Migration
  def up
    add_column(:system_users, :last_contribution, :timestamp, :default => Time.now - 1.year)
  end

  def down
    remove_column :system_users, :last_contribution
  end
end
