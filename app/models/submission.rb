class Submission < ActiveRecord::Base
  validates :pdu, :presence => true
  validates :system_user_id, :presence => true

  belongs_to  :system_user
end
