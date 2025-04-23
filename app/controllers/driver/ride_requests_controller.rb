module Driver
    class RideRequestsController < ApplicationController
      before_action :require_driver
      before_action :set_ride_request, only: [:show, :update]
      
      def index
        @pending_rides = RideRequest.where(status: :pending).order(created_at: :asc)
        @my_rides = current_user.ride_requests.where(status: [:accepted, :in_progress]).order(created_at: :desc)
      end
      
      def show
        # Show details of a specific ride request
      end
      
      def update
        case params[:status]
        when "accept"
          # Only accept if it's still pending and the driver doesn't have an active ride
          if @ride_request.pending? && !current_user.ride_requests.where(status: [:accepted, :in_progress]).exists?
            @ride_request.update(
              status: :accepted,
              driver: current_user,
              accepted_at: Time.current
            )
            Notification.create_for_ride_status(@ride_request, "accepted")
            redirect_to driver_ride_request_path(@ride_request), notice: "Ride accepted successfully!"
          else
            redirect_to driver_ride_requests_path, alert: "Cannot accept this ride request."
          end
          
        when "pickup"
          # Mark that the driver has arrived at pickup location
          if @ride_request.accepted? && @ride_request.driver == current_user
            @ride_request.update(
              status: :in_progress,
              pickup_at: Time.current
            )
            Notification.create_for_ride_status(@ride_request, "in_progress")
            redirect_to driver_ride_request_path(@ride_request), notice: "Pickup confirmed!"
          else
            redirect_to driver_ride_request_path(@ride_request), alert: "Cannot update this ride status."
          end
          
        when "complete"
          # Mark ride as completed
          if @ride_request.in_progress? && @ride_request.driver == current_user
            @ride_request.update(
              status: :completed,
              completed_at: Time.current
            )
            Notification.create_for_ride_status(@ride_request, "completed")
            redirect_to driver_dashboard_index_path, notice: "Ride completed successfully!"
          else
            redirect_to driver_ride_request_path(@ride_request), alert: "Cannot complete this ride."
          end
        
        else
          redirect_to driver_ride_request_path(@ride_request), alert: "Invalid action."
        end
      end
      
      private
      
      def set_ride_request
        @ride_request = RideRequest.find(params[:id])
      end
    end
  end