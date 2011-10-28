class LinkBinariesToClient < ActiveRecord::Migration
  def up
    add_column :binaries, :client_id, :integer
  end

  def down
    remove_column :binaries, :client_id
  end
end
