class LinkJadFieldsToBinaries < ActiveRecord::Migration
  def up
    add_column :jad_fields, :binary_id, :integer
  end

  def down
    remove_column :jad_fields, :binary_id
  end
end
