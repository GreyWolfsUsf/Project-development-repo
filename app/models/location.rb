class Location < ApplicationRecord
    has_many :pickup_rides, class_name: 'RideRequest', foreign_key: 'pickup_location_id'
    has_many :dropoff_rides, class_name: 'RideRequest', foreign_key: 'dropoff_location_id'
    
    validates :name, presence: true
    validates :latitude, :longitude, presence: true
    
    # Location types: :academic_building, :residence_hall, :parking_lot, :bus_stop, :other
    enum :location_type, {
        academic_building: 0,
        residence_hall: 1,
        parking_lot: 2,
        bus_stop: 3,
        other: 4
      }
    
    # Calculate distance from another location (in miles)
    def distance_from(other_location)
      # Using the Haversine formula to calculate distance between two points on Earth
      # This could be replaced with a mapping API in production
      lat1, lon1 = self.latitude, self.longitude
      lat2, lon2 = other_location.latitude, other_location.longitude
      
      rad_per_deg = Math::PI/180
      earth_radius_miles = 3959
      
      # Calculate the deltas
      dlat = (lat2 - lat1) * rad_per_deg
      dlon = (lon2 - lon1) * rad_per_deg
      
      a = Math.sin(dlat/2)**2 + Math.cos(lat1*rad_per_deg) * Math.cos(lat2*rad_per_deg) * Math.sin(dlon/2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      
      earth_radius_miles * c
    end
  end