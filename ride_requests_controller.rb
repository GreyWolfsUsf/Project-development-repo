# app/controllers/ride_requests_controller.rb
class RideRequestsController < ApplicationController
  before_action :authenticate_user!

  def new
    @ride_request = RideRequest.new
  end

  def create
    @ride_request = current_user.ride_requests.build(ride_request_params)
    
    # Calculate estimated time before saving
    if params[:pickup_latitude] && params[:pickup_longitude] && 
       params[:dropoff_latitude] && params[:dropoff_longitude]
      estimated_time_service = Api::V1::EstimatedTimesController.new
      estimated_time_service.params = ActionController::Parameters.new({
        pickup_latitude: params[:pickup_latitude],
        pickup_longitude: params[:pickup_longitude],
        dropoff_latitude: params[:dropoff_latitude],
        dropoff_longitude: params[:dropoff_longitude]
      })
      
      @estimated_time = estimated_time_service.send(:calculate_ride_estimate)
      @ride_request.estimated_time = @estimated_time.to_json
    end

    if @ride_request.save
      redirect_to @ride_request, notice: 'Ride request was successfully created.'
    else
      render :new
    end
  end

  def show
    @ride_request = RideRequest.find(params[:id])
    @estimated_time = JSON.parse(@ride_request.estimated_time).symbolize_keys if @ride_request.estimated_time
  end

  private

  def ride_request_params
    params.require(:ride_request).permit(
      :pickup_location, :dropoff_location, 
      :pickup_latitude, :pickup_longitude, 
      :dropoff_latitude, :dropoff_longitude,
      :passenger_count, :scheduled_time
    )
  end
end