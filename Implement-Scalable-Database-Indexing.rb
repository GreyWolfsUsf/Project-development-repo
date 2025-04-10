# app/jobs/wait_time_calculator_job.rb
class WaitTimeCalculatorJob < ApplicationJob
  queue_as :default

  def perform(ride_request_id)
    ride_request = RideRequest.find(ride_request_id)
    # Expensive logic here
  end
end
