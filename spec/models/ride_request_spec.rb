require 'rails_helper'

RSpec.describe RideRequest, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      ride_request = build(:ride_request)
      expect(ride_request).to be_valid
    end
    
    it 'is not valid without a user' do
      ride_request = build(:ride_request, user: nil)
      expect(ride_request).not_to be_valid
    end
    
    it 'is not valid without a pickup location' do
      ride_request = build(:ride_request, pickup_location: nil)
      expect(ride_request).not_to be_valid
    end
    
    it 'is not valid without a dropoff location' do
      ride_request = build(:ride_request, dropoff_location: nil)
      expect(ride_request).not_to be_valid
    end
    
    it 'is not valid without passengers count' do
      ride_request = build(:ride_request, passengers_count: nil)
      expect(ride_request).not_to be_valid
    end
    
    it 'is not valid with negative passengers count' do
      ride_request = build(:ride_request, passengers_count: -1)
      expect(ride_request).not_to be_valid
    end
    
    it 'is not valid with more than 5 passengers' do
      ride_request = build(:ride_request, passengers_count: 6)
      expect(ride_request).not_to be_valid
    end
  end
  
  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      ride_request = create(:ride_request, user: user)
      expect(ride_request.user).to eq(user)
    end
    
    it 'belongs to a pickup location' do
      location = create(:location)
      ride_request = create(:ride_request, pickup_location: location)
      expect(ride_request.pickup_location).to eq(location)
    end
    
    it 'belongs to a dropoff location' do
      location = create(:location)
      ride_request = create(:ride_request, dropoff_location: location)
      expect(ride_request.dropoff_location).to eq(location)
    end
    
    it 'can belong to a driver' do
      driver = create(:driver)
      ride_request = create(:ride_request, driver: driver)
      expect(ride_request.driver).to eq(driver)
    end
  end
  
  describe 'status' do
    it 'defaults to pending status' do
      ride_request = create(:ride_request)
      expect(ride_request.status).to eq('pending')
      expect(ride_request.pending?).to be true
    end
    
    it 'can be set to accepted status' do
      ride_request = create(:accepted_ride)
      expect(ride_request.status).to eq('accepted')
      expect(ride_request.accepted?).to be true
    end
    
    it 'can be set to in_progress status' do
      ride_request = create(:in_progress_ride)
      expect(ride_request.status).to eq('in_progress')
      expect(ride_request.in_progress?).to be true
    end
    
    it 'can be set to completed status' do
      ride_request = create(:completed_ride)
      expect(ride_request.status).to eq('completed')
      expect(ride_request.completed?).to be true
    end
    
    it 'can be set to cancelled status' do
      ride_request = create(:cancelled_ride)
      expect(ride_request.status).to eq('cancelled')
      expect(ride_request.cancelled?).to be true
    end
  end
  
  describe '#estimated_wait_time' do
    before do
      # Create some pending rides
      3.times do |i|
        create(:pending_ride, created_at: (i+1).minutes.ago)
      end
    end
    
    it 'estimates wait time based on queue position' do
      new_ride = create(:pending_ride)
      # 3 rides ahead * 5 minutes per ride = 15 minutes
      expect(new_ride.estimated_wait_time).to eq(15)
    end
    
    it 'only counts pending rides in the queue' do
      # Add some non-pending rides that should be ignored
      create(:accepted_ride)
      create(:completed_ride)
      create(:cancelled_ride)
      
      new_ride = create(:pending_ride)
      # Still only 3 pending rides ahead
      expect(new_ride.estimated_wait_time).to eq(15)
    end
  end
end