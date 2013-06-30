class CreatePeriodicTasks < ActiveRecord::Migration
  def change
    create_table :periodic_tasks do |t|
      t.text        :task_name
      t.text        :identity
      t.text        :running_url
      t.timestamp   :last_successful
      t.integer     :seconds_period
      t.timestamps
    end
  end
end
