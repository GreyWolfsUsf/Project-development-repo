# spec/requests/api/v1/ride_requests_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::RideRequests", type: :request do
  let(:user) { create(:user) }
  let(:pickup_location) { create(:location, name: "Cooper Hall") }
  let(:dropoff_location) { create(:location, name: "Marshall Student Center") }
  let(:headers) { { "Authorization" => "Bearer #{token_for(user)}" } }
  
  before do
    # Stub the operating hours validation for testing
    allow_any_instance_of(RideRequest).to receive(:within_operating_hours).and_return(true)
  end

  describe "GET /api/v1/ride_requests" do
    it "returns a list of user's ride requests" do
      # Create ride requests
      create_list(:ride_request, 3, user: user)
      create(:ride_request) # Another user's request, shouldn't be returned

      get api_v1_ride_requests_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(3)
    end

    it "returns ride requests in descending order of creation" do
      older = create(:ride_request, user: user, created_at: 2.days.ago)
      newest = create(:ride_request, user: user, created_at: 1.hour.ago)
      middle = create(:ride_request, user: user, created_at: 1.day.ago)

      get api_v1_ride_requests_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response.first["id"]).to eq(newest.id)
      expect(json_response.last["id"]).to eq(older.id)
    end

    it "returns unauthorized without authentication" do
      get api_v1_ride_requests_path

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/ride_requests/:id" do
    let(:ride_request) { create(:ride_request, user: user) }

    it "returns the ride request details" do
      get api_v1_ride_request_path(ride_request), headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["id"]).to eq(ride_request.id)
      expect(json_response["pickup_location"]["id"]).to eq(ride_request.pickup_location_id)
      expect(json_response["dropoff_location"]["id"]).to eq(ride_request.dropoff_location_id)
    end

    it "returns not found for another user's ride request" do
      other_request = create(:ride_request)
      
      get api_v1_ride_request_path(other_request), headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/ride_requests" do
    let(:valid_params) do
      {
        ride_request: {
          pickup_location_id: pickup_location.id,
          dropoff_location_id: dropoff_location.id,
          passenger_count: 2,
          special_instructions: "I'll be waiting by the main entrance"
        }
      }
    end

    it "creates a new ride request with valid parameters" do
      expect {
        post api_v1_ride_requests_path, params: valid_params, headers: headers
      }.to change(RideRequest, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_response["pickup_location"]["id"]).to eq(pickup_location.id)
      expect(json_response["dropoff_location"]["id"]).to eq(dropoff_location.id)
      expect(json_response["passenger_count"]).to eq(2)
      expect(json_response["status"]).to eq("pending")
    end

    it "returns errors with invalid parameters" do
      invalid_params = valid_params.deep_merge(
        ride_request: { pickup_location_id: pickup_location.id, dropoff_location_id: pickup_location.id }
      )

      post api_v1_ride_requests_path, params: invalid_params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["errors"]).to include(/must be different from pickup location/i)
    end

    it "enqueues a dispatcher notification job" do
      expect {
        post api_v1_ride_requests_path, params: valid_params, headers: headers
      }.to have_enqueued_job(NotifyDispatcherJob)
    end

    it "validates passenger count limits" do
      too_many = valid_params.deep_merge(ride_request: { passenger_count: 6 })
      
      post api_v1_ride_requests_path, params: too_many, headers: headers
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["errors"]).to include(/passenger count/i)
    end
  end

  describe "PATCH /api/v1/ride_requests/:id" do
    let!(:ride_request) { create(:ride_request, user: user, status: :pending) }
    let(:new_dropoff) { create(:location, name: "Library") }
    let(:update_params) do
      {
        ride_request: {
          dropoff_location_id: new_dropoff.id,
          passenger_count: 3
        }
      }
    end

    it "updates a pending ride request" do
      patch api_v1_ride_request_path(ride_request), params: update_params, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["dropoff_location"]["id"]).to eq(new_dropoff.id)
      expect(json_response["passenger_count"]).to eq(3)
    end

    it "doesn't allow updating a non-pending ride" do
      ride_request.update(status: :in_progress)
      
      patch api_v1_ride_request_path(ride_request), params: update_params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /api/v1/ride_requests/:id/cancel" do
    it "cancels a pending ride request" do
      ride_request = create(:ride_request, user: user, status: :pending)
      
      post cancel_api_v1_ride_request_path(ride_request), headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["status"]).to eq("canceled")
    end

    it "cancels an accepted ride request" do
      ride_request = create(:ride_request, user: user, status: :accepted)
      
      post cancel_api_v1_ride_request_path(ride_request), headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["status"]).to eq("canceled")
    end

    it "doesn't allow canceling a completed ride" do
      ride_request = create(:ride_request, user: user, status: :completed)
      
      post cancel_api_v1_ride_request_path(ride_request), headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/ride_requests/active" do
    it "returns the user's active ride request if exists" do
      # Create a pending ride
      active_ride = create(:ride_request, user: user, status: :pending)
      # Create some non-active rides
      create(:ride_request, user: user, status: :completed)
      create(:ride_request, user: user, status: :canceled)

      get active_api_v1_ride_requests_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["id"]).to eq(active_ride.id)
    end

    it "returns null when no active ride exists" do
      # Only create non-active rides
      create(:ride_request, user: user, status: :completed)
      create(:ride_request, user: user, status: :canceled)

      get active_api_v1_ride_requests_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["active_request"]).to be_nil
    end
  end

  # Helper methods for testing
  def json_response
    JSON.parse(response.body)
  end

  def token_for(user)
    # This depends on your auth implementation - replace with your actual JWT generation
    JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
  end
end

# spec/requests/api/v1/locations_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::Locations", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{token_for(user)}" } }
  
  describe "GET /api/v1/locations" do
    before do
      create(:location, name: "Cooper Hall", building_code: "CPR")
      create(:location, name: "Marshall Student Center", building_code: "MSC")
      create(:location, name: "Library", building_code: "LIB")
    end

    it "returns all locations in alphabetical order" do
      get api_v1_locations_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(3)
      expect(json_response.first["name"]).to eq("Cooper Hall")
      expect(json_response.last["name"]).to eq("Marshall Student Center")
    end

    it "returns unauthorized without authentication" do
      get api_v1_locations_path

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/locations/search" do
    before do
      create(:location, name: "Cooper Hall", building_code: "CPR")
      create(:location, name: "Marshall Student Center", building_code: "MSC")
      create(:location, name: "Library", building_code: "LIB")
    end

    it "searches locations by name" do
      get search_api_v1_locations_path, params: { query: "hall" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(1)
      expect(json_response.first["name"]).to eq("Cooper Hall")
    end

    it "searches locations by building code" do
      get search_api_v1_locations_path, params: { query: "msc" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(1)
      expect(json_response.first["building_code"]).to eq("MSC")
    end

    it "returns empty array when no matches found" do
      get search_api_v1_locations_path, params: { query: "nonexistent" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_empty
    end
  end

  # Helper methods for testing
  def json_response
    JSON.parse(response.body)
  end

  def token_for(user)
    # This depends on your auth implementation - replace with your actual JWT generation
    JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
  end
end

# spec/models/ride_request_spec.rb
require 'rails_helper'

RSpec.describe RideRequest, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:pickup_location).class_name('Location') }
    it { should belong_to(:dropoff_location).class_name('Location') }
  end

  describe "validations" do
    it { should validate_presence_of(:pickup_location_id) }
    it { should validate_presence_of(:dropoff_location_id) }
    it { should validate_presence_of(:passenger_count) }
    it { should validate_numericality_of(:passenger_count).is_greater_than(0).is_less_than_or_equal_to(5) }
    it { should validate_presence_of(:status) }

    describe "custom validations" do
      let(:location) { create(:location) }
      let(:user) { create(:user) }
      
      it "validates that pickup and dropoff locations are different" do
        ride_request = RideRequest.new(
          user: user,
          pickup_location: location,
          dropoff_location: location,
          passenger_count: 1
        )
        
        expect(ride_request).not_to be_valid
        expect(ride_request.errors[:dropoff_location_id]).to include("must be different from pickup location")
      end
      
      context "operating hours" do
        before do
          # Unstub the method to test it
          allow_any_instance_of(RideRequest).to receive(:within_operating_hours).and_call_original
        end
        
        it "is valid during operating hours" do
          # Stub the current time to be within operating hours (e.g., 8 PM)
          allow(Time).to receive(:current).and_return(Time.zone.local(2025, 3, 14, 20, 0, 0))
          
          ride_request = build(:ride_request)
          expect(ride_request).to be_valid
        end
        
        it "is invalid outside operating hours" do
          # Stub the current time to be outside operating hours (e.g., 3 PM)
          allow(Time).to receive(:current).and_return(Time.zone.local(2025, 3, 14, 15, 0, 0))
          
          ride_request = build(:ride_request)
          expect(ride_request).not_to be_valid
          expect(ride_request.errors[:base]).to include("SAFE Team service is only available from 6:00 PM to 2:00 AM")
        end
      end
    end
  end

  describe "callbacks" do
    it "sets initial status to pending on create" do
      ride_request = build(:ride_request, status: nil)
      ride_request.valid?
      expect(ride_request.status).to eq("pending")
    end

    it "estimates arrival time on create" do
      ride_request = build(:ride_request, estimated_arrival_time: nil)
      ride_request.valid?
      expect(ride_request.estimated_arrival_time).not_to be_nil
    end
  end

  describe "scopes" do
    before do
      @active1 = create(:ride_request, status: :pending)
      @active2 = create(:ride_request, status: :accepted)
      @active3 = create(:ride_request, status: :in_progress)
      @inactive1 = create(:ride_request, status: :completed)
      @inactive2 = create(:ride_request, status: :canceled)
      
      @recent = create(:ride_request, created_at: 3.days.ago)
      @old = create(:ride_request, created_at: 10.days.ago)
    end

    it "active scope returns pending, accepted and in_progress rides" do
      active_rides = RideRequest.active
      expect(active_rides).to include(@active1, @active2, @active3)
      expect(active_rides).not_to include(@inactive1, @inactive2)
    end

    it "recent scope returns rides created within last week" do
      recent_rides = RideRequest.recent
      expect(recent_