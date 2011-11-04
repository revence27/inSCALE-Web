class CreateSystemUsers < ActiveRecord::Migration
  def change
    create_table :system_users do |t|
      t.text          :name
      t.text          :number
      t.text          :code
      t.integer       :client_id
      t.timestamps
    end
  end
end
