class Application < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :client
  validates :name, :presence => true
  validates :description, :presence => true
  validates :code, :presence => true
end
