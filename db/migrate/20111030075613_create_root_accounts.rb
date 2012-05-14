class CreateRootAccounts < ActiveRecord::Migration
  def change
    create_table :root_accounts do |t|
      t.text          :sha1_pass
      t.text          :sha1_salt
      t.timestamps
    end
  end
end
