class Publisher < ActiveRecord::Base
  has_many :applications
  validates :name, :presence => true
  validates :address, :presence => true

  # def applications
  #   Application.order('name ASC')
  # end
end
