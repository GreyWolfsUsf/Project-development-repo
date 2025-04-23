class HomeController < ApplicationController
    skip_before_action :require_login, only: [:index]
    
    def index
      if logged_in?
        case current_user.role
        when "admin"
          redirect_to admin_root_path
        when "driver"
          redirect_to driver_root_path
        else
          # For students, show active ride or form to request a new one
          @active_ride = current_user.ride_requests.where(status: [:pending, :accepted, :in_progress]).order(created_at: :desc).first
          @new_ride = RideRequest.new if @active_ride.nil?
          @locations = Location.where(active: true).order(:name)
          @notifications = current_user.notifications.where(read: false).order(created_at: :desc).limit(5)
        end
      else
        # For non-logged in users, show login page
        render :welcome
      end
    end
  end