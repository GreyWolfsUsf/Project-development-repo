class CreateRideRequests < ActiveRecord::Migration[7.0]
    def change
      create_table :ride_requests do |t|
        t.references :user, null: false, foreign_key: true
        t.references :driver, foreign_key: { to_table: :users }
        t.references :pickup_location, null: false, foreign_key: { to_table: :locations }
        t.references :dropoff_location, null: false, foreign_key: { to_table: :locations }
        t.integer :status, default: 0  # 0: pending, 1: accepted, 2: in_progress, 3: completed, 4: cancelled
        t.integer :passengers_count, default: 1
        t.text :special_instructions
        t.datetime :accepted_at
        t.datetime :pickup_at
        t.datetime :completed_at
        t.datetime :cancelled_at
  
        t.timestamps
      end
      
      add_index :ride_requests, :status
    end
  end