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

  def deliver msg, sdr = nil
    Feedback.create(message: msg, number: self.number, sender: 'inSCALE')
  end

  def self.vht_reminders
    SystemUser.all.each do |su|
      su.deliver("Hello, %s.\nThe work you do is very helpful. Please remember to submit your report for this week." % [su.name])
    end
  end

  def to_s
    "#{self.name} [#{self.code}]"
  end

  def self.monthly_motivation
    mon = Time.now.month
    msg = MotivationalMessage.where(:month => mon).first
    return unless msg
    SystemUser.all.each do |su|
      Feedback.create :message => msg.english, :tag => 'monthly motivation', :number => su.number
    end
    pt = PeriodicTask.get_by_identity('motivation')
    pt.last_successful = Time.now
    pt.save

    subs  = Submission.where('created_at >= ? AND created_at < ?', Time.now - 1.week, Time.now)
    addrs = AdminAddress.all.map do |x|
      x.latest  = Time.now
      x.save
      x.address
    end
    ans   = SubmissionsReport.file_dispatch('Weekly Data Summary' , addrs, subs)
    # ans.attachments[naming.join('-') + '.csv'] = ERB.new(File.read('app/views/statistics/csv.csv.erb')).result(binding)
    ans.deliver
  end

  def self.weekly_motivation
    SystemUser.all.each do |su|
      t2 = su.submissions.order('actual_time DESC').first.actual_time rescue nil
      next unless t2
      if (Time.now - t2) > 518399 then
        m = %[#{su.name or %[Hello #{su.code}]}, remember to submit your report for Sunday to Saturday last week.]
        Feedback.create :message => m, :number => su.number, :tag => 'weekly'
      end
    end
    pt = PeriodicTask.find_by_identity('remindvhts')
    pt.last_successful = Time.now
    pt.save

    subs  = Submission.where('created_at >= ? AND created_at < ?', Time.now - 1.month, Time.now)
    addrs = AdminAddress.all.map do |x|
      x.latest  = Time.now
      x.save
      x.address
    end
    ans   = SubmissionsReport.file_dispatch('Monthly Data Summary' , addrs, subs)
    # ans.attachments[naming.join('-') + '.csv'] = ERB.new(File.read('app/views/statistics/csv.csv.erb')).result(binding)
    ans.deliver
  end
end
