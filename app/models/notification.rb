class Notification < ApplicationRecord
    belongs_to :user
    belongs_to :ride_request, optional: true
    
    # Types: :ride_accepted, :driver_arrived, :ride_completed, :system_message
    enum :notification_type, {
        ride_accepted: 0,
        driver_arrived: 1, 
        ride_completed: 2,
        system_message: 3
      }
    
    validates :message, presence: true
    
    # Mark notification as read
    def mark_as_read
      self.update(read: true)
    end
    
    # Create a notification for a ride status change
    def self.create_for_ride_status(ride_request, status)
      message = case status
      when "accepted"
        "Your ride has been accepted by driver #{ride_request.driver.full_name}."
      when "in_progress"
        "Your driver has arrived at your pickup location."
      when "completed"
        "Your ride has been completed. Thank you for using SAFE Team!"
      end
      
      Notification.create(
        user: ride_request.user,
        ride_request: ride_request,
        notification_type: "ride_#{status}".to_sym,
        message: message
      )
    end
  end