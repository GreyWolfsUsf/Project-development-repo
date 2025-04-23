module Driver
    class DashboardController < ApplicationController
      before_action :require_driver
      
      def index
        # Show active ride the driver is handling
        @active_ride = current_user.ride_requests.where(status: [:accepted, :in_progress]).order(created_at: :desc).first
        
        # Show pending rides that need a driver
        @pending_rides = RideRequest.where(status: :pending).order(created_at: :asc).limit(10)
        
        # Show completed rides by this driver for reference
        @completed_rides = current_user.ride_requests.where(status: :completed).order(created_at: :desc).limit(5)
      end
    end
  end