FactoryBot.define do
    factory :user do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      email { "#{first_name.downcase}.#{last_name.downcase}@usf.edu" }
      password { "password123" }
      password_confirmation { "password123" }
      u_number { "U#{Faker::Number.number(digits: 8)}" }
      role { :student }
      
      trait :student do
        role { :student }
      end
      
      trait :driver do
        role { :driver }
      end
      
      trait :admin do
        role { :admin }
      end
      
      factory :student, traits: [:student]
      factory :driver, traits: [:driver]
      factory :admin, traits: [:admin]
    end
  end