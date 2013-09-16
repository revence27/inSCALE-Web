class Parish < ActiveRecord::Base
  has_many :system_users
  has_many :supervisors
end
