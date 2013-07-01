class SystemUser < ActiveRecord::Base
  has_many :user_tags
  has_many :submissions
  belongs_to  :client
  belongs_to  :supervisor
  belongs_to  :parish
  belongs_to  :district
  belongs_to  :village

  validates :name, :presence => true
  validates :number, :presence => true
  validates :client_id, :presence => true
  validates :supervisor_id, :presence => true

  def latest_feedback
    Feedback.where('number = ?', self.number).order('created_at DESC').first
  end
end
