# ride_request_lifecycle.rb

# Class to represent a single ride request and handle status transitions
class RideRequest
    attr_accessor :user_id, :driver_id, :status
  
    STATUSES = %w[pending assigned completed cancelled].freeze
    ACTIVE_STATUSES = %w[pending assigned].freeze
  
    def initialize(user_id)
      @user_id = user_id
      @driver_id = nil
      @status = 'pending'
    end
  
    def assign_driver(driver_id)
      raise "❌ Cannot assign driver unless status is 'pending'" unless status == 'pending'
  
      @driver_id = driver_id
      @status = 'assigned'
      puts "🚗 Driver #{driver_id} assigned to ride for user #{user_id}."
    end
  
    def complete_ride
      raise "❌ Cannot complete ride unless status is 'assigned'" unless status == 'assigned'
  
      @status = 'completed'
      puts "✅ Ride completed for user #{user_id}."
    end
  
    def cancel(initiator = 'user')
      if %w[pending assigned].include?(status)
        @status = 'cancelled'
        puts "🚫 Ride cancelled by #{initiator} for user #{user_id}."
      else
        raise "❌ Cannot cancel a ride already marked as '#{status}'"
      end
    end
  
    def to_s
      "Ride(user_id: #{user_id}, driver_id: #{driver_id}, status: #{status})"
    end
  end
  
  # Business Rule: A user can only have one active ride request at a time
  def user_has_active_request?(user_id, requests)
    requests.any? { |r| r.user_id == user_id && RideRequest::ACTIVE_STATUSES.include?(r.status) }
  end
  
  # ---------------------
  # 🚀 Simulate Lifecycle
  # ---------------------
  requests = []
  
  ride1 = RideRequest.new("user_42")
  requests << ride1
  puts "\n🔵 New ride created: #{ride1}"
  
  if user_has_active_request?("user_42", requests)
    puts "⚠️ User has an active ride — cannot request another."
  end
  
  ride1.assign_driver("driver_9")
  ride1.complete_ride
  
  puts "ℹ️ Current status: #{ride1.status}"
  puts ride1
  
  # Create another request after completion
  ride2 = RideRequest.new("user_42")
  requests << ride2
  puts "\n🔵 New ride created: #{ride2}"
  
  # Cancel it before assigning
  ride2.cancel
  
  puts "ℹ️ Final status: #{ride2.status}"
  puts ride2
  