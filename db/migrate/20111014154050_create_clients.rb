class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.text            :name
      t.text            :code
      t.text            :sha1_pass
      t.text            :sha1_salt
      t.timestamps
    end
  end
end
