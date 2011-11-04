class SystemUser < ActiveRecord::Base
  has_many :user_tags
  has_many :submissions
  belongs_to  :client
end
