class Client < ActiveRecord::Base
  has_many :binaries
  has_many :applications
end
