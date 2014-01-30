def make_inscale
  sha1_salt = rand.to_s
  sha1_pass = Digest::SHA1.new << "#{sha1_salt}kafeero"
  cl  = Client.create(name: 'inSCALE', code: 'inscale', sha1_pass: sha1_pass.to_s, sha1_salt: sha1_salt)
  if Supervisor.all.count < 1 then
    Supervisor.create(name: 'Default Supervisor', number: '256772344681')
  end
  cl
end

class ConfirmVhtLocations < ActiveRecord::Migration
  def up
    File.open(ENV['VHT_LOCATIONS'] || 'db/vhtlocs.txt') do |fch|
      $stderr.puts fch.gets
      fch.each_line do |ligne|
        cl    = Client.find_by_code('inscale')
        if cl.nil? then
          cl  = make_inscale()
        end
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
                                    sort_code:      rvcode.to_i
                                   )
          end
          su.name         = vname.split(/(\W+)/).map {|x| x.capitalize}.join($1)
          su.number       = "256#{phone}"[-12, 12]
          su.code         = rvcode
          # su.village_id   = vil.id
          # su.district_id  = dist.id
          su.sort_code    = rvcode.to_i
          su.save
        end
      end
    end
  end

  def down
    SystemUser.all.each do |su|
      su.delete if ((su.code.length > 4) rescue true)
    end
  end
end
