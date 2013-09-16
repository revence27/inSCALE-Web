class UserTag < ActiveRecord::Base
  belongs_to  :system_user

  validates :name, :presence => true

  def self.uniquely! user, name
    num = user
    unless user.is_a?(1.class) then
      num = user.id
    end
    if self.where(name: name, system_user_id: num).count.zero? then
      self.create name: name, system_user_id: num
    end
  end
end
