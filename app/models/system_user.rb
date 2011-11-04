class SystemUser < ActiveRecord::Base
  has_many :user_tags
  has_many :submissions
  belongs_to  :client

  validates :name, :presence => true
  validates :number, :presence => true
  validates :client_id, :presence => true
end
