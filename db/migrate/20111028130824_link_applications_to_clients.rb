class LinkApplicationsToClients < ActiveRecord::Migration
  def up
    add_column :applications, :client_id, :integer
  end

  def down
    remove_column :applications, :client_id
  end
end
