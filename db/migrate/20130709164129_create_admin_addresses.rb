class CreateAdminAddresses < ActiveRecord::Migration
  def change
    create_table :admin_addresses do |t|
      t.text            :address
      t.text            :name
      t.timestamp       :latest
      t.boolean         :biostat
      t.timestamps
    end
  end
end
