require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end
    
    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
    
    it 'is not valid with a non-USF email' do
      user = build(:user, email: 'test@gmail.com')
      expect(user).not_to be_valid
    end
    
    it 'is not valid without a first name' do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
    end
    
    it 'is not valid without a last name' do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
    end
    
    it 'is not valid without a U number' do
      user = build(:user, u_number: nil)
      expect(user).not_to be_valid
    end
    
    it 'is not valid with an improperly formatted U number' do
      user = build(:user, u_number: '12345678')
      expect(user).not_to be_valid
    end
    
    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@usf.edu')
      user = build(:user, email: 'test@usf.edu')
      expect(user).not_to be_valid
    end
    
    it 'is not valid with a duplicate U number' do
      create(:user, u_number: 'U12345678')
      user = build(:user, u_number: 'U12345678')
      expect(user).not_to be_valid
    end
  end
  
  describe 'associations' do
    it 'has many ride_requests' do
      user = create(:user)
      ride1 = create(:ride_request, user: user)
      ride2 = create(:ride_request, user: user)
      
      expect(user.ride_requests).to include(ride1, ride2)
    end
  end
  
  describe 'methods' do
    it 'returns full name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
  
  describe 'roles' do
    it 'defaults to student role' do
      user = create(:user)
      expect(user.role).to eq('student')
      expect(user.student?).to be true
    end
    
    it 'can be set to driver role' do
      user = create(:driver)
      expect(user.role).to eq('driver')
      expect(user.driver?).to be true
    end
    
    it 'can be set to admin role' do
      user = create(:admin)
      expect(user.role).to eq('admin')
      expect(user.admin?).to be true
    end
  end
end