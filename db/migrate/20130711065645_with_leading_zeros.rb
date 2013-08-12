class WithLeadingZeros < ActiveRecord::Migration
  def up
    SystemUser.all.each do |su|
      su.code = '0000' if su.code.nil?
      if su.code.length < 4 then
        su.code = %[0000#{su.code}][-4, 4]
        su.save rescue nil
      end
    end
  end

  def down
  end
end
