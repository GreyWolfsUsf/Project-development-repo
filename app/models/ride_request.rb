class RideRequest < ApplicationRecord
    belongs_to :user
    belongs_to :driver, class_name: 'User', optional: true
    belongs_to :pickup_location, class_name: 'Location'
    belongs_to :dropoff_location, class_name: 'Location'
    
    # Status: :pending, :accepted, :in_progress, :completed, :cancelled
    enum :status, { 
        pending: 0, 
        accepted: 1, 
        in_progress: 2, 
        completed: 3, 
        cancelled: 4 
      }, default: :pending
    
    validates :passengers_count, presence: true, 
              numericality: { greater_than: 0, less_than_or_equal_to: 5 }
    
    # Calculate estimated wait time based on queue position and average ride time
    def estimated_wait_time
      # Basic calculation: 5 minutes per ride in queue ahead of this one
      pending_rides_ahead = RideRequest.where(status: :pending)
                                        .where('created_at < ?', self.created_at)
                                        .count
      return pending_rides_ahead * 5
    end
    
    # Overrides the default to_json to include the wait time
    def as_json(options = {})
      super(options).merge(estimated_wait_time: estimated_wait_time)
    end
  end