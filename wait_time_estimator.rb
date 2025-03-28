# app/services/wait_time_estimator.rb

class WaitTimeEstimator
  TOTAL_GOLF_CARTS = 20
  AVERAGE_RIDE_DURATION_MINUTES = 15 # in minutes

  def initialize
    @active_requests = RideRequest.where(status: 'pending').count
  end

  def estimate_wait_time
    return 0 if @active_requests == 0

    # Calculate how many "batches" of rides are needed
    rides_per_batch = TOTAL_GOLF_CARTS
    batches_needed = (@active_requests.to_f / rides_per_batch).ceil

    # Estimated wait time is batch count * average ride duration
    estimated_wait_time = batches_needed * AVERAGE_RIDE_DURATION_MINUTES
    estimated_wait_time
  end
end
#this code should work
