class OutOfTheDarkness < ActiveRecord::Migration
  def up
    eatharp = District.find_by_name 'Kiryandongo'
    eatdung = District.find_by_name 'Kiryadongo'
    SystemUser.where(district_id: eatdung.id).each do |usr|
      usr.district_id = eatharp.id
      usr.save
    end
    eatdung.delete
  end

  def down
  end
end
