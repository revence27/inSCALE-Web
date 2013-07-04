# encoding: UTF-8
DEFAULT_PHONE_NUMBER      = '256700000000'
DEFAULT_CLIENT_NAME       = 'inSCALE'

def clean_number num
  '256' + num.strip.gsub(/^256/, '')
end

class IncorporateVhts < ActiveRecord::Migration
  def up
    File.open(ENV['VHTS'] || 'db/inscale-vhts.txt') do |fch|
      actsup  = nil
      actdist = nil
      actsubc = nil
      actclnt = Client.find_by_name DEFAULT_CLIENT_NAME
      fch.each_line do |ligne|
        pieces  = ligne.strip.split("\t")
        if pieces.length == 10 then
          actdist = pieces[0]
          actsubc = pieces[1]
          sname   = pieces[3]
          sname   = "Supervisor (#{actdist} #{actsubc}) Not Named" unless sname.strip != ''
          actsup  = Supervisor.create(:name => sname, :number => DEFAULT_PHONE_NUMBER)
        else
          if pieces.length == 7 then
            if actsup.number == DEFAULT_PHONE_NUMBER then
              actsup.number = clean_number(pieces[0])
              actsup.save
            end
          end
        end
        diff  = 10 - pieces.length
        if pieces.length > 5 then
          nom = %[#{pieces[5 - diff]} #{pieces[4 - diff]}]
          cod = pieces[6 - diff].strip
          num = clean_number(pieces[7 - diff])
          par = pieces[8 - diff]
          vil = pieces[9 - diff]
          par = 'Unspecified' unless par.strip != ''
          vil = 'Unspecified' unless vil.strip != ''
          begin
            usr = SystemUser.create :name => nom, :number => num, :code => cod, :supervisor_id => actsup.id, :client_id => actclnt.id
            ['Script-registered', actdist, actsubc, %[#{vil}-village], %[#{par}-parish]].each do |tag|
              usr.user_tags << UserTag.create(:name => tag)
            end
            usr.save
          rescue Exception => e

          end
        end
        if pieces.length > 0 and pieces.length < 6 then
          puts %[#{pieces.length} #{pieces.inspect}]
        end
      end
    end
  end

  def down
    Supervisor.all.each do |supervisor|
      etcetera  = []
      SystemUser.where(:supervisor_id => supervisor.id).each do |sysu|
        etcetera << "\tDeleted user [#{sysu.number}] #{sysu.name} (#{sysu.code}): #{sysu.user_tags.map {|x| x.name}.join(', ')}"
      end
      supervisor.delete
      puts "Deleted supervisor [#{supervisor.number}] #{supervisor.name}"
      puts etcetera
      puts "#{'==========' * 8}\n\n"
    end
  end
end
