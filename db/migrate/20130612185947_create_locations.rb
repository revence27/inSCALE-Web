require 'json'

class CreateLocations < ActiveRecord::Migration
  # def change
  #   create_table :locations do |t|
  #   
  #     t.timestamps
  #   end
  # end

  def up
    # File.open(ENV['LOCATIONS_FILE'] || 'db/locations.json') do |fch|
    #   allocs  = JSON.parse(fch.read)
    #   allocs.each do |loc|
    #     raise Exception.new('Create entries of parishes.')
    #   end
    # end
    create_table :districts do |t|
      t.text  :name
      t.float :xpos
      t.float :ypos
    end
    create_table :parishes do |t|
      t.text  :name
      t.float :xpos
      t.float :ypos
    end
    create_table :villages do |t|
      t.text  :name
      t.float :xpos
      t.float :ypos
    end
  end

  def down
    # Will it ever be necessary to delete? We can just always correct on the CreateLocations#up.
    drop_table :districts
    drop_table :parishes
    drop_table :villages
  end
end
