class MoveErrors < ActiveRecord::Migration
  def up
    PendingPdu.from_system_errors!
  end

  def down
  end
end
