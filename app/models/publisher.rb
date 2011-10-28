class Publisher < ActiveRecord::Base
  has_many :applications

  # def applications
  #   Application.order('name ASC')
  # end
end
