class Supervisor < ActiveRecord::Base
  has_many :system_users
  belongs_to  :location
  belongs_to  :parish
end
