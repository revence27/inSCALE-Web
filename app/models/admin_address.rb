class AdminAddress < ActiveRecord::Base
  scope :biostat, where(:biostat => true)
  scope :admins, where(:biostat => false)
end
