class MessagesWithExtraData < ActiveRecord::Migration
  def up
    add_column :feedbacks, :system_response, :text
  end

  def down
    remove_column :feedbacks, :system_response
  end
end
