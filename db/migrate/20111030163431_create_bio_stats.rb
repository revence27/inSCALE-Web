class CreateBioStats < ActiveRecord::Migration
  def change
    create_table :bio_stats do |t|
      t.text        :name
      t.text        :sha1_pass
      t.text        :sha1_salt
      t.timestamps
    end
  end
end
