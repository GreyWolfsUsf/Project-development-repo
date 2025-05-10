# db/migrate/YYYYMMDDHHMMSS_create_locations.rb
class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.timestamps
    end
    
    add_index :locations, :code, unique: true
    add_index :locations, [:latitude, :longitude]
  end
end