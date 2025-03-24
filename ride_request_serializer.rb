# app/serializers/ride_request_serializer.rb
class RideRequestSerializer < ActiveModel::Serializer
  attributes :id, :pickup_location, :dropoff_location, 
             :pickup_latitude, :pickup_longitude, 
             :dropoff_latitude, :dropoff_longitude,
             :status, :passenger_count, :special_instructions,
             :scheduled_time, :estimated_fare, :created_at, :updated_at
  
  # Only include these attributes if they're present
  attributes :accepted_at, :started_at, :completed_at, :canceled_at, :final_fare, if: -> { object.attributes.key?('accepted_at') }
  
  belongs_to :user, serializer: UserSimpleSerializer
  belongs_to :driver, serializer: DriverSerializer, if: -> { object.driver.present? }
end

# app/serializers/user_simple_serializer.rb
class UserSimpleSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
end

# app/serializers/driver_serializer.rb
class DriverSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :rating, :vehicle_info
  
  def vehicle_info
    object.driver_profile&.vehicle_info
  end
  
  def rating
    object.driver_profile&.average_rating || 0
  end
end