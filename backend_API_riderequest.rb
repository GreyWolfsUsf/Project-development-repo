# MODELS

# app/models/ride_request.rb
class RideRequest < ApplicationRecord
  belongs_to :user
  belongs_to :pickup_location, class_name: 'Location'
  belongs_to :dropoff_location, class_name: 'Location'
  
  enum status: {
    pending: 0,
    accepted: 1,
    in_progress: 2,
    completed: 3,
    canceled: 4
  }
  
  validates :pickup_location_id, presence: true
  validates :dropoff_location_id, presence: true
  validates :passenger_count, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  validates :status, presence: true
  validate :locations_must_be_different
  validate :within_operating_hours
  
  before_validation :set_initial_status, on: :create
  before_validation :estimate_arrival_time, on: :create
  
  scope :active, -> { where(status: [:pending, :accepted, :in_progress]) }
  scope :recent, -> { where('created_at > ?', 7.days.ago) }
  
  def cancel
    update(status: :canceled)
  end
  
  def estimated_wait_time_in_minutes
    ((estimated_arrival_time - Time.current) / 60).ceil if estimated_arrival_time
  end
  
  private
  
  def set_initial_status
    self.status ||= :pending
  end
  
  def estimate_arrival_time
    # This would typically involve actual logic based on current demand, available drivers, etc.
    # For now, we'll use a simple estimate of 10-20 minutes from now
    self.estimated_arrival_time = Time.current + rand(10..20).minutes unless self.estimated_arrival_time
  end
  
  def locations_must_be_different
    if pickup_location_id == dropoff_location_id
      errors.add(:dropoff_location_id, "must be different from pickup location")
    end
  end
  
  def within_operating_hours
    # Assuming SAFE Team operates from 6:00 PM to 2:00 AM
    current_time = Time.current
    start_hour = 18 # 6:00 PM
    end_hour = 2 # 2:00 AM
    
    current_hour = current_time.hour
    
    # Check if current time is within operating hours
    is_operating = if end_hour < start_hour
                     current_hour >= start_hour || current_hour < end_hour
                   else
                     current_hour >= start_hour && current_hour < end_hour
                   end
    
    unless is_operating
      errors.add(:base, "SAFE Team service is only available from 6:00 PM to 2:00 AM")
    end
  end
end

# app/models/location.rb
class Location < ApplicationRecord
  has_many :pickup_requests, class_name: 'RideRequest', foreign_key: 'pickup_location_id'
  has_many :dropoff_requests, class_name: 'RideRequest', foreign_key: 'dropoff_location_id'
  
  validates :name, presence: true
  validates :address, presence: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :building_code, uniqueness: true, allow_blank: true
  
  scope :alphabetical, -> { order(name: :asc) }
  
  def coordinates
    [latitude, longitude]
  end
end

# CONTROLLERS

# app/controllers/api/v1/ride_requests_controller.rb
module Api
  module V1
    class RideRequestsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_ride_request, only: [:show, :update, :cancel]
      
      def index
        @ride_requests = current_user.ride_requests.recent.order(created_at: :desc)
        render json: @ride_requests
      end
      
      def show
        render json: @ride_request
      end
      
      def create
        @ride_request = current_user.ride_requests.build(ride_request_params)
        
        if @ride_request.save
          # Notify SAFE Team dispatchers about new request
          NotifyDispatcherJob.perform_later(@ride_request)
          
          render json: @ride_request, status: :created
        else
          render json: { errors: @ride_request.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        # Only allow updating specific fields based on current status
        if @ride_request.pending? && @ride_request.update(update_params)
          render json: @ride_request
        else
          render json: { errors: @ride_request.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def cancel
        if @ride_request.pending? || @ride_request.accepted?
          @ride_request.cancel
          render json: @ride_request
        else
          render json: { error: "Cannot cancel a ride that is in progress or completed" }, status: :unprocessable_entity
        end
      end
      
      def active
        @active_request = current_user.ride_requests.active.first
        
        if @active_request
          render json: @active_request
        else
          render json: { active_request: nil }, status: :ok
        end
      end
      
      private
      
      def set_ride_request
        @ride_request = current_user.ride_requests.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Ride request not found" }, status: :not_found
      end
      
      def ride_request_params
        params.require(:ride_request).permit(
          :pickup_location_id, 
          :dropoff_location_id, 
          :passenger_count, 
          :scheduled_pickup_time,
          :special_instructions
        )
      end
      
      def update_params
        # Only allow updating certain fields if the request is still pending
        params.require(:ride_request).permit(:pickup_location_id, :dropoff_location_id, :passenger_count, :special_instructions)
      end
    end
  end
end

# app/controllers/api/v1/locations_controller.rb
module Api
  module V1
    class LocationsController < ApplicationController
      before_action :authenticate_user!
      
      def index
        @locations = Location.alphabetical
        render json: @locations
      end
      
      def search
        query = params[:query].to_s.downcase
        @locations = Location.where('lower(name) LIKE ? OR lower(building_code) LIKE ?', "%#{query}%", "%#{query}%")
                            .alphabetical
                            .limit(10)
        
        render json: @locations
      end
    end
  end
end

# ROUTES

# config/routes.rb
Rails.application.routes.draw do
  # ... existing routes
  
  namespace :api do
    namespace :v1 do
      resources :ride_requests, only: [:index, :show, :create, :update] do
        member do
          post :cancel
        end
        collection do
          get :active
        end
      end
      
      resources :locations, only: [:index] do
        collection do
          get :search
        end
      end
    end
  end
end

# SERIALIZERS (for JSON responses)

# app/serializers/ride_request_serializer.rb
class RideRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :passenger_count, :created_at, :estimated_arrival_time,
             :estimated_wait_time_in_minutes, :special_instructions, :scheduled_pickup_time
  
  belongs_to :pickup_location
  belongs_to :dropoff_location
  
  def estimated_wait_time_in_minutes
    object.estimated_wait_time_in_minutes
  end
end

# app/serializers/location_serializer.rb
class LocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :building_code, :latitude, :longitude
end

# BACKGROUND JOBS

# app/jobs/notify_dispatcher_job.rb
class NotifyDispatcherJob < ApplicationJob
  queue_as :default
  
  def perform(ride_request)
    # In a real application, this would integrate with your dispatcher notification system
    # For example, sending a notification to a dispatcher application or dashboard
    
    # Example code for future implementation:
    # DispatcherNotificationService.new(ride_request).notify
    
    # Log the notification for now
    Rails.logger.info "New ride request ##{ride_request.id} submitted by #{ride_request.user.email} " +
                     "from #{ride_request.pickup_location.name} to #{ride_request.dropoff_location.name}"
  end
end

# MIGRATIONS

# db/migrate/YYYYMMDDHHMMSS_create_locations.rb
class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :building_code
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      
      t.timestamps
    end
    
    add_index :locations, :building_code, unique: true
    add_index :locations, [:latitude, :longitude]
  end
end

# db/migrate/YYYYMMDDHHMMSS_create_ride_requests.rb
class CreateRideRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :ride_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pickup_location, null: false, foreign_key: { to_table: :locations }
      t.references :dropoff_location, null: false, foreign_key: { to_table: :locations }
      t.integer :status, default: 0, null: false
      t.integer :passenger_count, default: 1, null: false
      t.datetime :estimated_arrival_time
      t.datetime :scheduled_pickup_time
      t.text :special_instructions
      
      t.timestamps
    end
    
    add_index :ride_requests, :status
  end
end