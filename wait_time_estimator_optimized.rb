# app/services/wait_time_estimator_optimized.rb
#Estimated wait time (optimized) 
#FR-03 #34

class WaitTimeEstimator
    CACHE_TTL = 30.seconds
  
    def self.estimate(location_id)
      Rails.cache.fetch("wait_time_#{location_id}", expires_in: CACHE_TTL) do
        heavy_estimation_logic(location_id)
      end
    end
  
    def self.heavy_estimation_logic(location_id)
      # Simulate an expensive operation (e.g., database calls, AI model)
      sleep(0.2)  # simulate delay
      {
        'lib' => 5,
        'msc' => 10,
        'gym' => 8
      }[location_id]
    end
  end

  
  