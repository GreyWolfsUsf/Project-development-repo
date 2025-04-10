# app/controllers/ride_requests_controller.rb
class RideRequestsController < ApplicationController
  def create
    ride_request = RideRequest.new(ride_request_params)
    if ride_request.save
      render json: ride_request, status: :created
    else
      render json: { errors: ride_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ride_request_params
    params.require(:ride_request).permit(:pickup_location_id, :dropoff_location_id, :user_id, ...) # other params
  end
end
