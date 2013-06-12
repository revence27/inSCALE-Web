class Supervisor < ActiveRecord::Base
  has_many :system_users
  belongs_to  :location
end
