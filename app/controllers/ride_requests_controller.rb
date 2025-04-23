class RideRequestsController < ApplicationController
    before_action :require_student, except: [:show]
    before_action :set_ride_request, only: [:show, :edit, :update, :destroy, :cancel]
    before_action :authorize_ride_request, only: [:edit, :update, :destroy, :cancel]
    
    def index
      @active_ride = current_user.ride_requests.where(status: [:pending, :accepted, :in_progress]).order(created_at: :desc).first
      
      if @active_ride
        redirect_to @active_ride
      else
        @new_ride = RideRequest.new
        @locations = Location.where(active: true).order(:name)
      end
    end
    
    def show
      # Used by both students and drivers
    end
    
    def new
      # Check if user has any active rides
      if current_user.ride_requests.where(status: [:pending, :accepted, :in_progress]).exists?
        redirect_to ride_requests_path, alert: "You already have an active ride request."
        return
      end
      
      @ride_request = RideRequest.new
      @locations = Location.where(active: true).order(:name)
    end
    
    def create
      # Check if user has any active rides
      if current_user.ride_requests.where(status: [:pending, :accepted, :in_progress]).exists?
        redirect_to ride_requests_path, alert: "You already have an active ride request."
        return
      end
      
      @ride_request = current_user.ride_requests.build(ride_request_params)
      
      if @ride_request.save
        redirect_to @ride_request, notice: "Ride request created successfully!"
      else
        @locations = Location.where(active: true).order(:name)
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
      @locations = Location.where(active: true).order(:name)
    end
    
    def update
      if @ride_request.update(ride_request_params)
        redirect_to @ride_request, notice: "Ride request updated successfully!"
      else
        @locations = Location.where(active: true).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @ride_request.destroy
      redirect_to ride_requests_path, notice: "Ride request deleted successfully!"
    end
    
    def cancel
      if @ride_request.pending?
        @ride_request.update(status: :cancelled, cancelled_at: Time.current)
        redirect_to ride_requests_path, notice: "Ride request cancelled successfully!"
      else
        redirect_to @ride_request, alert: "Cannot cancel a ride that has already been accepted."
      end
    end
    
    def history
      @ride_requests = current_user.ride_requests
                                   .where(status: [:completed, :cancelled])
                                   .order(created_at: :desc)
                                   .page(params[:page])
                                   .per(10)
    end
    
    private
    
    def set_ride_request
      @ride_request = RideRequest.find(params[:id])
    end
    
    def authorize_ride_request
      unless @ride_request.user == current_user || current_user.driver? || current_user.admin?
        redirect_to root_path, alert: "You are not authorized to perform this action."
      end
    end
    
    def ride_request_params
      params.require(:ride_request).permit(:pickup_location_id, :dropoff_location_id, 
                                            :passengers_count, :special_instructions)
    end
  end