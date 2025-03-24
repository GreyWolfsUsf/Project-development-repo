# db/migrate/YYYYMMDDHHMMSS_create_ride_requests.rb
class CreateRideRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :ride_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :driver, foreign_key: { to_table: :users }, null: true
      
      t.string :pickup_location, null: false
      t.string :dropoff_location, null: false
      t.decimal :pickup_latitude, precision: 10, scale: 7, null: false
      t.decimal :pickup_longitude, precision: 10, scale: 7, null: false
      t.decimal :dropoff_latitude, precision: 10, scale: 7, null: false
      t.decimal :dropoff_longitude, precision: 10, scale: 7, null: false
      
      t.datetime :scheduled_time
      t.datetime :accepted_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :canceled_at
      
      t.integer :status, default: 0
      t.integer :passenger_count, default: 1
      t.text :special_instructions
      
      t.decimal :estimated_fare, precision: 10, scale: 2
      t.decimal :final_fare, precision: 10, scale: 2
      
      t.timestamps
    end
    
    add_index :ride_requests, :status
    add_index :ride_requests, :scheduled_time
  end
end