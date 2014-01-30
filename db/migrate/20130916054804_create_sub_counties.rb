class CreateSubCounties < ActiveRecord::Migration
  def change
    create_table :sub_counties do |t|
      t.text        :name
      t.integer     :xpos
      t.integer     :ypos
      t.timestamps
    end

    add_column :system_users, :sub_county_id, :integer

    File.open(ENV['VHT_LOCATIONS'] || 'db/vhtlocs.txt') do |fch|
      $stderr.puts fch.gets
      fch.each_line do |ligne|
        cl    = Client.find_by_code('inscale')
        sp    = Supervisor.all.first
        _, distr, subc, parish, village, healthf, vname, phone, vcode, *etc = ligne.split("\t")
        if etc.length > 0 then
          vil   = Village.find_by_name(village.capitalize)
          if vil.nil? then
            vil = Village.create(name: village.capitalize, xpos: 0.0, ypos: 0.0)
          end
          par   = Parish.find_by_name(parish.capitalize)
          if par.nil? then
            par = Parish.create(name: parish.capitalize, xpos: 0.0, ypos: 0.0)
          end
          suby  = SubCounty.find_by_name(subc.capitalize)
          if suby.nil? then
            suby = SubCounty.create(name: subc.capitalize, xpos: 0.0, ypos: 0.0)
          end
          dist  = District.find_by_name(distr.capitalize)
          if dist.nil? then
            dist = District.create(name: distr.capitalize, xpos: 0.0, ypos: 0.0)
          end
          rvcode  = "0000#{vcode}"[-4, 4]
          su      = SystemUser.find_by_code(rvcode)
          if su.nil? then
            su  = SystemUser.create(
                                    name:           vname.split(/(\W+)/).map {|x| x.capitalize}.join($1),
                                    number:         "256#{phone}"[-12, 12],
                                    code:           rvcode,
                                    client_id:      cl.id,
                                    supervisor_id:  sp.id,
                                    # parish_id:      par.id,
                                    # village_id:     vil.id,
                                    # district_id:    dist.id,
                                    # sub_county_id:  suby.id,
                                    sort_code:      rvcode.to_i
                                   )
          end
          su.name           = vname.split(/(\W+)/).map {|x| x.capitalize}.join($1)
          su.number         = "256#{phone}"[-12, 12]
          su.code           = rvcode
          # su.village_id     = vil.id
          # su.parish_id      = par.id
          # su.sub_county_id  = suby.id
          # su.district_id    = dist.id
          su.sort_code      = rvcode.to_i
          su.save

          {village: vil, parish: par, subcounty: suby, district: dist}.each do |place, lox|
            tn  = "#{lox.name.gsub(/[^a-z0-9]i/, ' ').strip.gsub(/\s+/, '-')}-#{place}"
            tag = UserTag.where(system_user_id: su.id, name: tn)
            if tag.count < 1 then
              UserTag.create(system_user_id: su.id, name: tn)
            end
          end
        end
      end
    end

    [District, SubCounty, Parish, Village].each do |loc|
      loc.all.each do |part|
        part.name = part.name.gsub(/[^a-z0-9]/i, ' ').strip.split.map do |piece|
          piece.strip.capitalize
        end.join(' ')
        part.save
      end
    end
  end

  def down
    UserTag.all.each do |ut|
      ut.delete if ut.name =~ /[a-z]+-[a-z]/
    end

    remove_column :system_users, :sub_county_id
  end
end
