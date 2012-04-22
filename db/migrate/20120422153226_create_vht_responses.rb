class CreateVhtResponses < ActiveRecord::Migration
  def change
    create_table :vht_responses do |t|
      t.integer       :week
      t.text          :many_kids
      t.text          :no_kids
      t.timestamps
    end
  end
end
