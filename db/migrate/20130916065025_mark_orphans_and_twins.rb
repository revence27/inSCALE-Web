class MarkOrphansAndTwins < ActiveRecord::Migration
  def up
    add_column :supervisors, :dormant, :boolean, :null => false, :default => false

    $stderr.puts %[Go and “delete” the supervisors who suck.]

    prev  = ''
    SystemUser.order('sort_code ASC').each do |su|
      if su.code == prev then
        SystemUser.where(code: su.code).each do |sysu|
          UserTag.uniquely! sysu, 'repeated-code'
        end
      end
      prev  = su.code
    end
  end

  def down
    remove_column :supervisors, :dormant
  end
end
