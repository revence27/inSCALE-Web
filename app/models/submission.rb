class Submission < ActiveRecord::Base
  validates :pdu, :presence => true
  belongs_to  :system_user
end
