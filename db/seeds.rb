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

clt = Client.create :name => 'inSCALE', :code => 'inscale', :sha1_pass => '', :sha1_salt => ''
