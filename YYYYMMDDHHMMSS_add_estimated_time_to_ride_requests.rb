# db/migrate/YYYYMMDDHHMMSS_add_estimated_time_to_ride_requests.rb
class AddEstimatedTimeToRideRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :ride_requests, :estimated_time, :text
  end
end