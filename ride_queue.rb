# Feature: Ride Queue Processing (FR-04)

# app/models/ride.rb
class Ride < ApplicationRecord
    validates :pickup_location, :dropoff_location, presence: true
    after_create :enqueue_ride
  
    private
    def enqueue_ride
      RideQueue.add(self)
    end
  end
  