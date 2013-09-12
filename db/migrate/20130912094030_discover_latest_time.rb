class DiscoverLatestTime < ActiveRecord::Migration
  def up
    SystemUser.all.each do |usr|
      usr.last_contribution = (CollectedInfo.where('vht_code = ?', [usr.code]).order('created_at DESC').first.created_at || nil rescue nil)
      usr.save
    end
  end

  def down
  end
end
