clt = Client.create :name => 'inSCALE', :code => 'inscale', :sha1_pass => '5b217b69570860cc7d8af1393c378eecab4a840f', :sha1_salt => 'tusuza emyoyo'

pub = Publisher.create :name => 'inSCALE Questionnaires', :address => 'http://inscale.1st.ug/'

app =  Application.create(
        :name => 'Weekly Report',
 :description => 'ICCM VHT weekly phone-based report',
 :code        => 'vht {timestamp} {vhtcode} {number Number of males:} {number Number of females:} {number Number measured for respiratory rate:} {number Number of RDTs positive:} {number Number of RDTs negative:} {number Number with diarrhoea:} {number Number with fast breathing:} {number Number with fever:} {number Number with danger sign:} {number Number treated within 24 hours:} {number Number treated with ORS:} {number Number treated with Zinc tablet:} {number Number treated with Amoxycillin:} {number Number treated with ACT:} {number Number referred:} {bool Do you currently have stocks of all medicines?} {bool Do you currently have RDTs in stock?} {number Total number of new-borns seen:} {number Number of new-borns with danger signs:} {number Number of new-borns referred:}'
  )

pub.applications << app
clt.applications << app

pub.save

rut = RootAccount.create :sha1_pass => '13366d232cec0d05a076b5a2fe4fe5ecbda3895f', :sha1_salt => 'christ est le roi'
bst = BioStat.create :sha1_pass => '06287f7a367d7325e764bc0823ddd77348d79c15', :sha1_salt => %[kan'emu kanabbiri], :name => 'Default Bio-statistician'


rev = SystemUser.create(:name => 'Revence Kalibwani',
                      :number => '+256772344681')
fra = SystemUser.create(:name => 'Francis Otim',
                      :number => '+256790862813')

clt.system_users << rev
clt.system_users << fra

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


clt.system_users << rev
clt.save
