class FeedbackIsTagged < ActiveRecord::Migration
  def up
    add_column :feedbacks, :tag, :text, :default => 'routine', :null => false
  end

  def down
    remove_column :feedbacks, :tag, :text, :default => 'routine', :null => false
  end
end
