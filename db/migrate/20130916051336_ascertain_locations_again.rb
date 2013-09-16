class AscertainLocationsAgain < ActiveRecord::Migration
  def up
    Supervisor.where(parish_id: nil).each do |sup|
      par           = Parish.create(name: "Parish of St. #{sup.name}")
      sup.parish_id = par.id
      sup.save
    end
    SystemUser.where(parish_id: nil).each do |usr|
      usr.parish_id = usr.supervisor.parish_id
      usr.save
    end
    SystemUser.where(district_id: nil).each do |usr|
      sup             = usr.supervisor
      usr.district_id = SystemUser.where('district_id IS NOT NULL AND supervisor_id = ?', [sup.id]).first.district_id
      UserTag.create(name: 'Automatic-district', system_user_id: usr.id)
      usr.save
    end
  end

  def down
  end
end
