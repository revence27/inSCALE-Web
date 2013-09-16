class Supervisor < ActiveRecord::Base
  has_many :system_users
  belongs_to  :location
  belongs_to  :parish

  def goodly_html
    (self.dormant ? %[<i>#{self.name}</i>] : %[<a href="/supervisors/#{self.id}">#{self.name}</a>]) + %[<sub class="quicksub">#{self.number[3 .. -1]}</sub>]
  end
end
