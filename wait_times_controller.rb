# app/controllers/api/v1/wait_times_controller.rb
#FR-03 #31
# Handles API requests to retrieve the estimated wait time for a SAFE Team ride at a given location

module Api
    module V1
      class WaitTimesController < ApplicationController
        def show
          location_id = params[:location_id]
  
          # Simulated logic: Replace this with real queue/wait-time computation
          wait_time_minutes = WaitTimeEstimator.estimate(location_id)
  
          if wait_time_minutes
            render json: {
              location_id: location_id,
              estimated_wait_time_minutes: wait_time_minutes,
              status: 'success'
            }, status: :ok
          else
            render json: {
              error: 'Invalid location ID or wait time unavailable',
              status: 'error'
            }, status: :not_found
          end
        end
      end
    end
  end
  