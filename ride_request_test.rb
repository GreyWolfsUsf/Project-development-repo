# test/models/ride_request_test.rb
require 'test_helper'

class RideRequestTest < ActiveSupport::TestCase
  setup do
    @user = users(:passenger)
    @valid_attributes = {
      user: @user,
      pickup_location: "123 Main St",
      dropoff_location: "456 Elm St",
      pickup_latitude: 37.7749,
      pickup_longitude: -122.4194,
      dropoff_latitude: 37.7833,
      dropoff_longitude: -122.4167,
      passenger_count: 2
    }
  end
  
  test "should be valid with valid attributes" do
    ride_request = RideRequest.new(@valid_attributes)
    assert ride_request.valid?
  end
  
  test "should not be valid without required attributes" do
    required_attributes = [:pickup_location, :dropoff_location, :pickup_latitude, 
                          :pickup_longitude, :dropoff_latitude, :dropoff_longitude, :passenger_count]
    
    required_attributes.each do |attribute|
      invalid_attributes = @valid_attributes.dup
      invalid_attributes.delete(attribute)
      
      ride_request = RideRequest.new(invalid_attributes)
      assert_not ride_request.valid?, "RideRequest should not be valid without #{attribute}"
    end
  end
  
  test "should validate latitude and longitude ranges" do
    invalid_coordinates = [
      { pickup_latitude: 91, error_on: :pickup_latitude },
      { pickup_latitude: -91, error_on: :pickup_latitude },
      { pickup_longitude: 181, error_on: :pickup_longitude },
      { pickup_longitude: -181, error_on: :pickup_longitude },
      { dropoff_latitude: 91, error_on: :dropoff_latitude },
      { dropoff_latitude: -91, error_on: :dropoff_latitude },
      { dropoff_longitude: 181, error_on: :dropoff_longitude },
      { dropoff_longitude: -181, error_on: :dropoff_longitude }
    ]
    
    invalid_coordinates.each do |invalid_coord|
      attributes = @valid_attributes.merge(invalid_coord.except(:error_on))
      ride_request = RideRequest.new(attributes)
      assert_not ride_request.valid?
      assert ride_request.errors.key?(invalid_coord[:error_on])
    end
  end
  
  test "should validate passenger count is positive" do
    ride_request = RideRequest.new(@valid_attributes.merge(passenger_count: 0))
    assert_not ride_request.valid?
    assert ride_request.errors.key?(:passenger_count)
    
    ride_request = RideRequest.new(@valid_attributes.merge(passenger_count: -1))
    assert_not ride_request.valid?
    assert ride_request.errors.key?(:passenger_count)
  end
  
  test "should validate scheduled time is in the future" do
    ride_request = RideRequest.new(@valid_attributes.merge(scheduled_time: 1.hour.ago))
    assert_not ride_request.valid?
    assert ride_request.errors.key?(:scheduled_time)
    
    ride_request = RideRequest.new(@valid_attributes.merge(scheduled_time: 1.hour.from_now))
    assert ride_request.valid?
  end
  
  test "should set initial status to pending" do
    ride_request = RideRequest.create!(@valid_attributes)
    assert_equal "pending", ride_request.status
  end
  
  test "should calculate distance between pickup and dropoff" do
    ride_request = RideRequest.new(@valid_attributes)
    distance = ride_request.calculate_distance
    
    # The distance between the test coordinates is roughly 1.3 km
    # Allow for some floating point imprecision
    assert_in_delta 1.3, distance, 0.1
  end
  
  test "should calculate estimated fare" do
    ride_request = RideRequest.new(@valid_attributes)
    fare = ride_request.estimated_fare
    
    # Base fare (5.0) + distance fare (1.3 * 1.5)
    expected_fare = 5.0 + (1.3 * 1.5)
    assert_in_delta expected_fare, fare, 0.1
  end
  
  test "should determine if request can be updated" do
    ride_request = RideRequest.create!(@valid_attributes)
    
    assert ride_request.can_be_updated?, "Should be updatable when pending"
    
    ride_request.update(status: :searching)
    assert ride_request.can_be_updated?, "Should be updatable when searching"
    
    ride_request.update(status: :accepted)
    assert_not ride_request.can_be_updated?, "Should not be updatable when accepted"
  end
  
  test "should determine if request can be canceled" do
    ride_request = RideRequest.create!(@valid_attributes)
    
    assert ride_request.can_be_canceled?, "Should be cancelable when pending"
    
    ride_request.update(status: :searching)
    assert ride_request.can_be_canceled?, "Should be cancelable when searching"
    
    ride_request.update(status: :accepted)
    assert ride_request.can_be_canceled?, "Should be cancelable when accepted"
    
    ride_request.update(status: :in_progress)
    assert_not ride_request.can_be_canceled?, "Should not be cancelable when in progress"
  end
end