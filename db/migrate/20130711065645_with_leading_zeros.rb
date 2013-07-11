class WithLeadingZeros < ActiveRecord::Migration
  def up
    SystemUser.all.each do |su|
      if su.code.length < 4 then
        su.code = %[0000#{su.code}][-4, 4]
        su.save
      end
    end
  end

  def down
  end
end
