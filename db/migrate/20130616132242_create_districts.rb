class CreateDistricts < ActiveRecord::Migration
  def change
    return
    create_table :districts do |t|
      t.timestamps
    end
  end
end
