class Location < ActiveRecord::Base
  has_one   :supervisor
end
