class UserTag < ActiveRecord::Base
  belongs_to  :system_user

  validates :name, :presence => true
end
