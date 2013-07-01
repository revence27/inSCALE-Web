class InitialTasks < ActiveRecord::Migration
  def initialize *args
    super(*args)
    @them = [
      {:task_name => 'Remind VHTs to Send Submissions', :identity => 'remindvhts', :running_url => 'http://localhost:3000/weekly', :seconds_period => 7.days, :last_successful => 0.days},
      {:task_name => 'Monthly Motivations', :identity => 'motivation', :running_url => 'http://localhost:3000/monthly', :seconds_period => 1.month, :last_successful => 0.days}
    ]
  end

  def up
    @them.each do |pt|
      PeriodicTask.create(:task_name => pt[:task_name], :identity => pt[:identity], :running_url => pt[:running_url], :seconds_period => pt[:seconds_period], :last_successful => Time.now - (1.day + pt[:seconds_period].to_i.seconds))
    end
  end

  def down
    @them.each do |pt|
      PeriodicTask.find_by_identity(pt[:identity]).delete
    end
  end
end
