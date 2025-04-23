class User < ApplicationRecord
    has_secure_password
    has_many :ride_requests
    has_many :notifications  # Add this line
    has_one_attached :avatar

    validates :email, presence: true, uniqueness: true, 
              format: { with: /\A[\w+\-.]+@usf\.edu\z/i, message: "must be a USF email" }
    validates :first_name, :last_name, presence: true
    validates :u_number, presence: true, uniqueness: true, 
              format: { with: /\AU\d{8}\z/, message: "must be in format U12345678" }
    
    # Roles: :student, :driver, :admin
    enum :role, { student: 0, driver: 1, admin: 2 }, default: :student
    
    def full_name
      "#{first_name} #{last_name}"
    end
  end