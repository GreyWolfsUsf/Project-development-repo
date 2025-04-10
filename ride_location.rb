# Feature: Ride Location Selection (FR-05)

# app/models/location.rb
class Location < ApplicationRecord
    validates :name, presence: true, uniqueness: true
  
    def self.usf_buildings
      ["Library", "MSC", "Engineering Building", "Business Building", "Rec Center"]
    end
    
  end
  
  # app/controllers/rides_controller.rb
  class RidesController < ApplicationController
    def new
      @locations = Location.usf_buildings
    end
  
    def create
      @ride = Ride.new(ride_params)
      if @ride.save
        redirect_to @ride, notice: 'Ride request submitted successfully.'
      else
        render :new
      end
    end
  
    private
    def ride_params
      params.require(:ride).permit(:pickup_location, :dropoff_location)
    end
  end
