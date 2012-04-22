class SystemUser < ActiveRecord::Base
  has_many :user_tags
  has_many :submissions
  belongs_to  :client
  belongs_to  :supervisor

  validates :name, :presence => true
  validates :number, :presence => true
  validates :client_id, :presence => true
  validates :supervisor_id, :presence => true
end
