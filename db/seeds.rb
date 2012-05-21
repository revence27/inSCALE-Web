clt = Client.create :name => 'inSCALE', :code => 'inscale', :sha1_pass => '5b217b69570860cc7d8af1393c378eecab4a840f', :sha1_salt => 'tusuza emyoyo'

pub = Publisher.create :name => 'inSCALE Questionnaires', :address => 'http://208.86.227.216:3000/'

app =  Application.create(
        :name => 'Weekly Report',
 :description => 'ICCM VHT weekly phone-based report',
 :code        => 'vht {timestamp} {vhtcode} {number Number of males children (SEX M):} {number Number of female children (SEX F):} {number Number of RDT results positive (+):} {number Number of RDT results negative (-):} {number Number of children with Diarrhoea:} {number Number of children with fast breathing:} {number Number of children with fever:}  {number Number of children with Danger sign:} {number Number of children treated within 24 hours:} {number Number treated with ORS:} {number Number treated with Zinc 1/2 tablet:} {number Number treated with Zinc 1 tablet:} {number Number treated with Amoxicillin Red:} {number Number treated with Amoxicillin Green:} {number Number treated with ACT - Coartem Yellow:} {number Number treated with ACT - Coartem Blue:} {number Number treated with Rectal Artesunate 1 capsule:} {number Number treated with Rectal Artesunate 2 capsules:} {number Number treated with Rectal Artesunate 4 capsules:} {number Number of children referred:} {number Number of children who died:} {number Number of male newborns (SEX M):} {number Number of female newborns (SEX F):} {number Number of Home visit Day 1:} {number Number of Home visit Day 3:} {number Number of Home visit Day 7:} {number Number of newborns with Danger signs:} {number Number of newborns referred:} {number Number of newborns with Yellow MUAC:} {number Number of newborns with Red MUAC/Oedema:} {number ORS balance:} {number Zinc balance:} {number Yellow ACT balance:} {number Blue ACT balance:} {number Red Amoxicillin balance:} {number Green Amoxicillin balance:} {number RDT balance:} {number Rectal Artesunate balance:} {choice Pairs%20of%20gloves%20balance MT5:More%20than%205:LT5:Less%20than%205} {choice MUAC%20Tape Y:Present:N:Absent}'
  )

pub.applications << app
clt.applications << app

pub.save

rut = RootAccount.create :sha1_pass => '13366d232cec0d05a076b5a2fe4fe5ecbda3895f', :sha1_salt => 'christ est le roi'
bst = BioStat.create :sha1_pass => '06287f7a367d7325e764bc0823ddd77348d79c15', :sha1_salt => %[kan'emu kanabbiri], :name => 'Default Bio-statistician'

sup = Supervisor.create(:name => 'Nnyabo Madam Supervisor',
                      :number => '256718202639')

rev = SystemUser.create(:name => 'Revence Kalibwani',
                      :number => '+256772344681',
               :supervisor_id => sup.id)
fra = SystemUser.create(:name => 'Francis Otim',
                      :number => '+256790862813',
               :supervisor_id => sup.id)
mck = SystemUser.create(:name => 'Mock VHT',
                      :number => '+256771620961',
               :supervisor_id => sup.id)

clt.system_users << rev
clt.system_users << fra
clt.system_users << mck

rev.submissions << Submission.create(:pdu => 'Just a testing message.')
rev.submissions << Submission.create(:pdu => 'Yet another testing message.')

fra.submissions << Submission.create(:pdu => 'Incoherent nonsense.')
fra.submissions << Submission.create(:pdu => 'A waste of bytes.')

rev.user_tags << UserTag.create(:name => 'Entebbe')
rev.user_tags << UserTag.create(:name => 'Developer')
rev.user_tags << UserTag.create(:name => 'Male')

rev.save

fra.user_tags << UserTag.create(:name => 'Luzira')
fra.user_tags << UserTag.create(:name => 'Prisoner')
fra.user_tags << UserTag.create(:name => 'Male')

fra.save


mck.user_tags << UserTag.create(:name => 'Mock')

clt.system_users << rev
clt.save

mf  = ENV['MESSAGES'] || 'db/Immediate feedback messages.csv'
File.open(mf) do |fch|
  fch.each_line do |lgn|
    wk, _, rsp1, __, rsp2, *etc = lgn.split("\t")
    older = VhtResponse.find_by_week(wk.to_i)
    if older then
      older.many_kids = rsp1
      older.no_kids   = rsp2
    else
      older = VhtResponse.new :week      => wk.to_i,
                              :many_kids => rsp1[1 ... -1],
                              :no_kids   => rsp2[1 ... -1]
    end
    older.save
  end
end
