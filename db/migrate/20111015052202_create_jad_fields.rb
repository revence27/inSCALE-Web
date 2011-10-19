class CreateJadFields < ActiveRecord::Migration
  def change
    create_table :jad_fields do |t|
      t.text        :key
      t.text        :value
      t.timestamps
    end
  end
end
