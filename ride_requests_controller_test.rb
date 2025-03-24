# test/controllers/api/v1/ride_requests_controller_test.rb
require 'test_helper'

class Api::V1::RideRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:passenger)
    @driver = users(:driver)
    @ride_request = ride_requests(:pending)
    
    # Assuming you have authentication set up, sign in the user
    sign_in_as(@user)
    
    @valid_params = {
      ride_request: {
        pickup_location: "123 Main St",
        dropoff_location: "456 Elm St",
        pickup_latitude: 37.7749,
        pickup_longitude: -122.4194,
        dropoff_latitude: 37.7833,
        dropoff_longitude: -122.4167,
        passenger_count: 2,
        special_instructions: "Please call when you arrive"
      }
    }
  end
  
  test "should create ride request" do
    assert_difference('RideRequest.count') do
      post api_v1_ride_requests_url, params: @valid_params, as: :json
    end
    
    assert_response :created
    
    response_data = JSON.parse(response.body)
    assert_equal @valid_params[:ride_request][:pickup_location], response_data['pickup_location']
    assert_equal @valid_params[:ride_request][:dropoff_location], response_data['dropoff_location']
    assert_equal @user.id, response_data['user']['id']
    assert_equal 'pending', response_data['status']
  end
  
  test "should not create ride request with invalid params" do
    invalid_params = {
      ride_request: {
        pickup_location: "123 Main St",
        # Missing required fields
      }
    }
    
    assert_no_difference('RideRequest.count') do
      post api_v1_ride_requests_url, params: invalid_params, as: :json
    end
    
    assert_response :unprocessable_entity
    response_data = JSON.parse(response.body)
    assert response_data['errors'].present?
  end
  
  test "should show ride request" do
    get api_v1_ride_request_url(@ride_request), as: :json
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal @ride_request.id, response_data['id']
    assert_equal @ride_request.status, response_data['status']
  end
  
  test "should not show ride request belonging to another user" do
    other_user_request = ride_requests(:other_user)
    
    get api_v1_ride_request_url(other_user_request), as: :json
    assert_response :not_found
  end
  
  test "should allow driver to view ride request" do
    sign_in_as(@driver)
    
    get api_v1_ride_request_url(@ride_request), as: :json
    assert_response :success
  end
  
  test "should update ride request" do
    update_params = {
      ride_request: {
        special_instructions: "Updated instructions"
      }
    }
    
    patch api_v1_ride_request_url(@ride_request), params: update_params, as: :json
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal update_params[:ride_request][:special_instructions], response_data['special_instructions']
  end
  
  test "should not update ride request that cannot be updated" do
    @ride_request.update(status: :in_progress)
    
    update_params = {
      ride_request: {
        special_instructions: "Updated instructions"
      }
    }
    
    patch api_v1_ride_request_url(@ride_request), params: update_params, as: :json
    assert_response :unprocessable_entity
  end
  
  test "should cancel ride request" do
    post cancel_api_v1_ride_request_url(@ride_request), as: :json
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal 'canceled', response_data['status']
    assert_not_nil response_data['canceled_at']
  end
  
  test "should not cancel ride request that cannot be canceled" do
    @ride_request.update(status: :completed)
    
    post cancel_api_v1_ride_request_url(@ride_request), as: :json
    assert_response :unprocessable_entity
  end
  
  private
  
  def sign_in_as(user)
    # This is a placeholder for your actual authentication method
    # Adjust this based on your authentication setup
    #
    # Example with Devise and JWT:
    # post user_session_path, params: { user: { email: user.email, password: 'password' } }
    # token = response.headers['Authorization']
    # @request.headers['Authorization'] = token
    #
    # For testing purposes, you might use a test helper:
    @request.headers['Authorization'] = "Bearer #{generate_token_for(user)}" if defined?(@request)
  end
  
  def generate_token_for(user)
    # Placeholder for your token generation logic
    "test_token_for_#{user.id}"
  end
end