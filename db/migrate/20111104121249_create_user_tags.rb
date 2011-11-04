class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.text          :name
      t.integer       :system_user_id
      t.timestamps
    end
  end
end
