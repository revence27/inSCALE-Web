class CollectedInfo < ActiveRecord::Base
  belongs_to :submission

  def pdu
    self.submission.pdu
  end

  def responses
    sysu  = SystemUser.find_by_code(self.vht_code)
    return [] unless sysu
    nxts  = Submission.where(['created_at > ?', self.submission.created_at]).order('created_at ASC').first
    qry   = Feedback.where(['number = ?', sysu.number]).where(['created_at >= ?', self.created_at]).order('created_at ASC')
    if nxts then
      qry = qry.where('created_at < ?', [nxts.created_at])
    end
    qry
  end
end
