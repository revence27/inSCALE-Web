# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

pub = Publisher.create :name => 'inSCALE Questionnaires', :address => 'http://inscale.1st.ug/'
pub.applications << (
  Application.create(:name        => 'VHT Details',
                     :description => 'Information about the VHT',
                     :code        => '{show Not yet ready!}{exit}',
                     :client_id   => 1)
)
pub.applications << (
  Application.create(:name        => 'Weekly Report',
                     :description => 'The weekly VHT reports.',
                     :code        => '{show Not yet ready!}{exit}',
                     :client_id   => 1)
)
pub.applications << (
  Application.create(:name        => 'Just to Test',
                     :description => 'This, as the name says, is just a test.',
                     :code        => '{show Not yet ready!}{exit}',
                     :client_id   => 1)
)
pub.save

clt = Client.create :name => 'inSCALE', :code => 'inscale', :sha1_pass => '5b217b69570860cc7d8af1393c378eecab4a840f', :sha1_salt => 'tusuza emyoyo'
rut = RootAccount.create :sha1_pass => '13366d232cec0d05a076b5a2fe4fe5ecbda3895f', :sha1_salt => 'christ est le roi'
bst = BioStat.create :sha1_pass => '06287f7a367d7325e764bc0823ddd77348d79c15', :sha1_salt => %[kan'emu kanabbiri], :name => 'Default Bio-statistician'


rev = SystemUser.create(:name => 'Revence Kalibwani',
                      :number => '+256772344681')

rev.submissions << Submission.create(:pdu => 'Just a testing message.')
rev.submissions << Submission.create(:pdu => 'Yet another testing message.')

rev.user_tags << UserTag.new(:name => 'Entebbe')
rev.user_tags << UserTag.new(:name => 'Developer')
rev.user_tags << UserTag.new(:name => 'Male')

rev.save

clt.system_users << rev
clt.save
