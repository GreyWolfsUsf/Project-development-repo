# app/services/wait_time_estimator.rb
#FR-03 #31
#Estimation of the wait time

class WaitTimeEstimator
    def self.estimate(location_id)
      # These are all placeholders (I need to get a list of all the USF locations) & (replace with real data/algorithm)
      {
        'lib' => 5,
        'msc' => 10,
        'gym' => 8
      }[location_id]
    end
  end
  