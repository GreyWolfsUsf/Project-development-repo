# app/models/ride_request.rb
class RideRequest < ApplicationRecord
  belongs_to :user
  belongs_to :driver, optional: true
  
  enum status: {
    pending: 0,       # Initial state when request is created
    searching: 1,     # System is searching for drivers
    accepted: 2,      # A driver has accepted the request
    in_progress: 3,   # Ride is in progress
    completed: 4,     # Ride has been completed
    canceled: 5,      # Ride was canceled by user or system
    expired: 6        # No drivers accepted within timeframe
  }
  
  validates :pickup_location, presence: true
  validates :dropoff_location, presence: true
  validates :pickup_latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :pickup_longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :dropoff_latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :dropoff_longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :passenger_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  validate :scheduled_time_in_future, if: -> { scheduled_time.present? }
  
  after_create :set_initial_status
  
  def can_be_updated?
    %w[pending searching].include?(status)
  end
  
  def can_be_canceled?
    %w[pending searching accepted].include?(status)
  end
  
  def estimated_fare
    # Placeholder for fare calculation logic
    # This could be a more complex calculation based on distance, time, demand, etc.
    distance = calculate_distance
    base_fare = 5.0
    distance_fare = distance * 1.5
    base_fare + distance_fare
  end
  
  def calculate_distance
    # Haversine formula to calculate distance between two coordinates
    earth_radius = 6371 # km
    
    lat1_rad = pickup_latitude * Math::PI / 180
    lat2_rad = dropoff_latitude * Math::PI / 180
    
    delta_lat = (dropoff_latitude - pickup_latitude) * Math::PI / 180
    delta_lng = (dropoff_longitude - pickup_longitude) * Math::PI / 180
    
    a = Math.sin(delta_lat/2) * Math.sin(delta_lat/2) +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) *
        Math.sin(delta_lng/2) * Math.sin(delta_lng/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    
    earth_radius * c
  end
  
  private
  
  def scheduled_time_in_future
    if scheduled_time.present? && scheduled_time <= Time.current
      errors.add(:scheduled_time, "must be in the future")
    end
  end
  
  def set_initial_status
    # Default to pending if no status was set
    pending! if status.nil?
  end
end