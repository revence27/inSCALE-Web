class AwakeOSleeperAndChristWillShineOnYou < ActiveRecord::Migration
  def up
    SystemUser.where('last_contribution IS NULL').each do |su|
      UserTag.create name: 'dormant', system_user_id: su.id
    end
  end

  def down
  end
end
