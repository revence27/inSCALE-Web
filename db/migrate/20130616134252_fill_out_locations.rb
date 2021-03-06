class FillOutLocations < ActiveRecord::Migration
  def up
    add_column :supervisors, :parish_id, :integer
    add_column :system_users, :parish_id, :integer
    add_column :system_users, :village_id, :integer
    add_column :system_users, :district_id, :integer

    UserTag.all.each do |tag|
      sysu  = tag.system_user
      next unless sysu and sysu.supervisor
      supr  = sysu.supervisor
      if tag.name =~ /^(.*)-parish$/ then
        if $1 then
          par = $1.capitalize
          pop = Parish.find_by_name par
          pob = Parish.create(:name => par) unless pob
          if supr.parish_id.nil? then
            supr.parish_id = pob.id
            supr.save
          end
          sysu.parish_id = pob.id
        end
      else
        if tag.name =~ /^(.*)-district/ then
          if $1 then
            dist              = $1.capitalize
            dst               = District.find_by_name dist
            dst               = District.create(:name => dist) unless dst
            sysu.district_id  = dst.id
          end
        else
          if tag.name =~ /^(.*)-village$/ then
            if $1 then
              vil             = $1.capitalize
              vlg             = Village.find_by_name vil
              vlg             = Village.create(:name => vil) unless vlg
              sysu.village_id = vlg.id
            end
          end
        end
      end
      sysu.save
    end
  end

  def down
    remove_column :supervisors, :parish_id
    remove_column :system_users, :parish_id
    remove_column :system_users, :village_id
    remove_column :system_users, :district_id
    District.all.each {|d| d.delete}
    Parish.all.each {|d| d.delete}
    Village.all.each {|d| d.delete}
  end
end
