class CreateLocations < ActiveRecord::Migration[7.0]
    def change
      create_table :locations do |t|
        t.string :name, null: false
        t.text :description
        t.decimal :latitude, precision: 10, scale: 7, null: false
        t.decimal :longitude, precision: 10, scale: 7, null: false
        t.integer :location_type, default: 0
        t.boolean :active, default: true  # Can be used to temporarily disable a location
  
        t.timestamps
      end
      
      add_index :locations, [:latitude, :longitude]
      add_index :locations, :name
    end
  end