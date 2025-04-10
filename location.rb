# app/models/location.rb
class Location < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true, format: { with: /\A[A-Z0-9]+\z/, message: "only allows uppercase letters and numbers" }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  
  def coordinates
    [latitude, longitude]
  end
  
  def self.find_nearby(lat, lng, radius_km = 10)
    # Haversine formula could be implemented here to find locations within a radius
    # This is a simplified version
    where("ABS(latitude - ?) <= ? AND ABS(longitude - ?) <= ?", lat, radius_km/111.0, lng, radius_km/111.0)
  end
end