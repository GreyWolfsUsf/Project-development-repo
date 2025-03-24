# app/controllers/api/v1/ride_requests_controller.rb
module Api
  module V1
    class RideRequestsController < ApplicationController
      before_action :authenticate_user!
      
      def create
        @ride_request = current_user.ride_requests.build(ride_request_params)
        
        if @ride_request.save
          # Trigger background job to find drivers (optional)
          FindDriversJob.perform_later(@ride_request.id) if defined?(FindDriversJob)
          
          render json: @ride_request, status: :created
        else
          render json: { errors: @ride_request.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def show
        @ride_request = RideRequest.find_by(id: params[:id])
        
        if @ride_request && (current_user.id == @ride_request.user_id || current_user.driver?)
          render json: @ride_request
        else
          render json: { error: "Ride request not found" }, status: :not_found
        end
      end
      
      def update
        @ride_request = current_user.ride_requests.find_by(id: params[:id])
        
        if @ride_request.nil?
          render json: { error: "Ride request not found" }, status: :not_found
          return
        end
        
        if @ride_request.can_be_updated?
          if @ride_request.update(ride_request_update_params)
            render json: @ride_request
          else
            render json: { errors: @ride_request.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Ride request cannot be updated in its current state" }, status: :unprocessable_entity
        end
      end
      
      def cancel
        @ride_request = current_user.ride_requests.find_by(id: params[:id])
        
        if @ride_request.nil?
          render json: { error: "Ride request not found" }, status: :not_found
          return
        end
        
        if @ride_request.can_be_canceled?
          @ride_request.canceled!
          render json: @ride_request
        else
          render json: { error: "Ride request cannot be canceled in its current state" }, status: :unprocessable_entity
        end
      end
      
      private
      
      def ride_request_params
        params.require(:ride_request).permit(:pickup_location, :dropoff_location, :pickup_latitude, 
                                             :pickup_longitude, :dropoff_latitude, :dropoff_longitude, 
                                             :scheduled_time, :passenger_count, :special_instructions)
      end
      
      def ride_request_update_params
        params.require(:ride_request).permit(:special_instructions)
      end
    end
  end
end