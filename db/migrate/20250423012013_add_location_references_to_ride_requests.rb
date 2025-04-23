class AddLocationReferencesToRideRequests < ActiveRecord::Migration[8.0]
  def change
    add_reference :ride_requests, :pickup_location, foreign_key: { to_table: :locations }
    add_reference :ride_requests, :dropoff_location, foreign_key: { to_table: :locations }
  end
end