require 'rails_helper'

RSpec.describe RideRequest, type: :model do
  let(:user) { User.create!(email: 'student@usf.edu', password: 'password123') }

  describe 'Status transitions' do
    it 'defaults to pending on creation' do
      request = RideRequest.create!(user: user, pickup_location: 'Library', dropoff_location: 'Dorm')
      expect(request.status).to eq('pending')
    end

    it 'can change from pending to assigned' do
      request = RideRequest.create!(user: user, status: 'pending', pickup_location: 'Library', dropoff_location: 'Dorm')
      request.update!(status: 'assigned')
      expect(request.status).to eq('assigned')
    end

    it 'cannot change directly from pending to completed (invalid transition)' do
      request = RideRequest.create!(user: user, status: 'pending', pickup_location: 'Library', dropoff_location: 'Dorm')
      expect {
        request.update!(status: 'completed')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'Queue order logic' do
    it 'sorts requests by creation time' do
      first = RideRequest.create!(user: user, pickup_location: 'A', dropoff_location: 'B', created_at: 5.minutes.ago)
      second = RideRequest.create!(user: user, pickup_location: 'C', dropoff_location: 'D', created_at: 2.minutes.ago)
      third = RideRequest.create!(user: user, pickup_location: 'E', dropoff_location: 'F', created_at: 1.minute.ago)

      ordered = RideRequest.queue_order
      expect(ordered).to eq([first, second, third])
    end
  end

  describe 'Preventing duplicate active requests' do
    it 'does not allow user to have two active requests' do
      RideRequest.create!(user: user, status: 'pending', pickup_location: 'Library', dropoff_location: 'Dorm')

      duplicate = RideRequest.new(user: user, status: 'pending', pickup_location: 'Gym', dropoff_location: 'Dining Hall')
      expect(duplicate.valid?).to be_falsey
      expect(duplicate.errors[:base]).to include('You already have an active ride request.')
    end

    it 'allows new request if previous one is completed' do
      RideRequest.create!(user: user, status: 'completed', pickup_location: 'Library', dropoff_location: 'Dorm')

      new_request = RideRequest.new(user: user, status: 'pending', pickup_location: 'Gym', dropoff_location: 'Dining Hall')
      expect(new_request.valid?).to be_truthy
    end
  end
end
