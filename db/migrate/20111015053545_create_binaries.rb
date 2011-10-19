class CreateBinaries < ActiveRecord::Migration
  def change
    create_table :binaries do |t|
      t.text        :jar_b64
      t.text        :jar_sha1
      t.text        :release_note
      t.timestamps
    end
  end
end
