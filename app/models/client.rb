class Client < ActiveRecord::Base
  has_many :binaries
  has_many :applications
  has_many :system_users
end
