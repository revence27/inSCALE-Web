class MoveMisses < ActiveRecord::Migration
  def up
    PendingPdu.from_missed_codes!
  end

  def down
  end
end
