class Supervisor < ActiveRecord::Base
  has_many :system_users
end
