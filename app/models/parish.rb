class Parish < ActiveRecord::Base
  has_many :system_user
  has_many :supervisor
end
