class Application < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :client
end
