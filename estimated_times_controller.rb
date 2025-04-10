# app/controllers/api/v1/estimated_times_controller.rb
module Api
  module V1
    class EstimatedTimesController < ApplicationController
      before_action :authenticate_user!

      def calculate
        # Validate input parameters
        unless params[:pickup_latitude] && params[:pickup_longitude] && 
               params[:dropoff_latitude] && params[:dropoff_longitude]
          render json: { error: "Missing required location parameters" }, 
                 status: :unprocessable_entity
          return
        end

        # Fetch estimated times
        ride_estimate = calculate_ride_estimate

        render json: ride_estimate, status: :ok
      end

      private

      def calculate_ride_estimate
        # Gather input coordinates
        pickup_lat = params[:pickup_latitude].to_f
        pickup_lng = params[:pickup_longitude].to_f
        dropoff_lat = params[:dropoff_latitude].to_f
        dropoff_lng = params[:dropoff_longitude].to_f

        # Calculate distance
        distance = calculate_distance(pickup_lat, pickup_lng, dropoff_lat, dropoff_lng)

        # Estimate times (these are placeholder calculations)
        estimated_driving_time = calculate_driving_time(distance)
        estimated_arrival_time = Time.current + estimated_driving_time
        
        # Find nearby available drivers
        nearby_drivers = find_nearby_drivers(pickup_lat, pickup_lng)
        
        # Calculate driver arrival time
        driver_arrival_time = nearby_drivers.any? ? 
          estimate_driver_arrival(pickup_lat, pickup_lng, nearby_drivers) : 
          nil

        {
          distance_km: distance.round(2),
          estimated_driving_time_minutes: estimated_driving_time.to_i,
          estimated_arrival_time: estimated_arrival_time.iso8601,
          estimated_driver_arrival_minutes: driver_arrival_time&.to_i,
          available_drivers: nearby_drivers.count
        }
      end

      def calculate_distance(lat1, lng1, lat2, lng2)
        # Haversine formula for calculating distance between two coordinates
        earth_radius = 6371 # km
        
        # Convert degrees to radians
        lat1_rad = lat1 * Math::PI / 180
        lat2_rad = lat2 * Math::PI / 180
        
        delta_lat = (lat2 - lat1) * Math::PI / 180
        delta_lng = (lng2 - lng1) * Math::PI / 180
        
        a = Math.sin(delta_lat/2) * Math.sin(delta_lat/2) +
            Math.cos(lat1_rad) * Math.cos(lat2_rad) *
            Math.sin(delta_lng/2) * Math.sin(delta_lng/2)
        
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
        
        earth_radius * c
      end

      def calculate_driving_time(distance)
        # Assume average speed of 50 km/h with some variation
        # Convert to minutes
        (distance / 50.0 * 60).ceil
      end

      def find_nearby_drivers(latitude, longitude, radius_km = 10)
        # Placeholder for driver search logic
        # In a real implementation, this would use spatial queries
        # to find drivers within a specific radius
        User.where(role: :driver)
            .joins(:driver_profile)
            .where(driver_profiles: { available: true })
            .select { |driver| 
              calculate_distance(
                latitude, 
                longitude, 
                driver.current_latitude, 
                driver.current_longitude
              ) <= radius_km 
            }
      end

      def estimate_driver_arrival(pickup_lat, pickup_lng, nearby_drivers)
        # Find the closest driver and estimate their arrival time
        closest_driver = nearby_drivers.min_by { |driver| 
          calculate_distance(
            pickup_lat, 
            pickup_lng, 
            driver.current_latitude, 
            driver.current_longitude
          )
        }

        return nil unless closest_driver

        # Calculate distance to pickup and estimate time
        driver_distance = calculate_distance(
          pickup_lat, 
          pickup_lng, 
          closest_driver.current_latitude, 
          closest_driver.current_longitude
        )

        # Assume driver's average speed is 50 km/h
        (driver_distance / 50.0 * 60).ceil
      end
    end
  end
end