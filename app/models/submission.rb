class Submission < ActiveRecord::Base
  validates :pdu, :presence => true
end
