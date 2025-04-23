class CreateRideRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :ride_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.integer :passengers_count
      t.text :special_instructions
      t.datetime :accepted_at
      t.datetime :pickup_at
      t.datetime :completed_at
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
