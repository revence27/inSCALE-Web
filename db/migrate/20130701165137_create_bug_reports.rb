class CreateBugReports < ActiveRecord::Migration
  def change
    create_table :bug_reports do |t|
      t.text          :description
      t.text          :contact
      t.text          :url
      t.timestamps
    end
  end
end
