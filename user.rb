class User < ApplicationRecord
  # Add validations if needed
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
end