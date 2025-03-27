# test/controllers/api/v1/estimated_times_controller_test.rb
require 'test_helper'

class Api::V1::EstimatedTimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:passenger)
    sign_in_as(@user)
  end

  test "should calculate estimated time with valid coordinates" do
    # San Francisco coordinates as an example
    get api_v1_estimated_times_url, params: {
      pickup_latitude: 37.7749,
      pickup_longitude: -122.4194,
      dropoff_latitude: 37.7833,
      dropoff_longitude: -122.4167
    }, as: :json

    assert_response :success

    response_data = JSON.parse(response.body)
    
    # Validate response structure
    assert response_data['distance_km']
    assert response_data['estimated_driving_time_minutes']
    assert response_data['estimated_arrival_time']
    assert response_data.key?('estimated_driver_arrival_minutes')
    assert response_data.key?('available_drivers')
  end

  test "should return error for missing coordinates" do
    get api_v1_estimated_times_url, params: {
      pickup_latitude: 37.7749
      # Missing other coordinates
    }, as: :json

    assert_response :unprocessable_entity

    response_data = JSON.parse(response.body)
    assert response_data['error']
  end

  private

  def sign_in_as(user)
    # Implement your authentication method here
    # This is a placeholder and should match your actual authentication logic
    @request.headers['Authorization'] = "Bearer #{generate_token_for(user)}"
  end

  def generate_token_for(user)
    # Placeholder for token generation
    "test_token_for_#{user.id}"
  end
end