# wait_time_factors.rb

# A simple Ruby script to simulate the impact of factors on ride request wait time

# Define weights for each factor (can be adjusted based on data or tuning)
WEIGHTS = {
  active_requests: 1.5,
  available_vehicles: -2.0,
  driver_distance: 0.8,
  time_of_day_factor: 1.0,
  server_load: 0.5
}

# Example inputs (simulate a scenario)
inputs = {
  active_requests: 25,         # number of ride requests
  available_vehicles: 10,      # number of free drivers
  driver_distance: 3.2,        # in kilometers
  time_of_day_factor: 1.2,     # multiplier for rush hour or late night (1 = normal)
  server_load: 0.7             # load from 0 (idle) to 1 (fully loaded)
}

def calculate_wait_time(inputs)
  wait_time = 0

  wait_time += inputs[:active_requests] * WEIGHTS[:active_requests]
  wait_time += inputs[:available_vehicles] * WEIGHTS[:available_vehicles]
  wait_time += inputs[:driver_distance] * WEIGHTS[:driver_distance]
  wait_time += inputs[:time_of_day_factor] * 5 * WEIGHTS[:time_of_day_factor] # scaled
  wait_time += inputs[:server_load] * 10 * WEIGHTS[:server_load]              # scaled

  wait_time = wait_time.round(2)
  wait_time < 0 ? 0 : wait_time
end

# Run the simulation
estimated_wait_time = calculate_wait_time(inputs)

# Output results
puts "📊 Simulation Results:"
puts "------------------------"
inputs.each do |key, value|
  label = key.to_s.split('_').map(&:capitalize).join(' ')
  puts "#{label}: #{value}"
end

puts "------------------------"
puts "⏱️  Estimated Wait Time: #{estimated_wait_time} minutes"
