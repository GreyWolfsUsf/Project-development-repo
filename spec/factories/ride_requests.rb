FactoryBot.define do
    factory :ride_request do
      association :user, factory: :student
      association :pickup_location, factory: :location
      association :dropoff_location, factory: :location
      passengers_count { Faker::Number.between(from: 1, to: 5) }
      status { :pending }
      special_instructions { Faker::Boolean.boolean(true_ratio: 0.3) ? Faker::Lorem.sentence : nil }
      
      # Ensure pickup and dropoff locations are different
      after(:build) do |ride_request|
        if ride_request.pickup_location == ride_request.dropoff_location
          ride_request.dropoff_location = create(:location)
        end
      end
      
      trait :pending do
        status { :pending }
      end
      
      trait :accepted do
        status { :accepted }
        association :driver, factory: :driver
        accepted_at { Time.current - 10.minutes }
      end
      
      trait :in_progress do
        status { :in_progress }
        association :driver, factory: :driver
        accepted_at { Time.current - 15.minutes }
        pickup_at { Time.current - 5.minutes }
      end
      
      trait :completed do
        status { :completed }
        association :driver, factory: :driver
        accepted_at { Time.current - 30.minutes }
        pickup_at { Time.current - 20.minutes }
        completed_at { Time.current - 5.minutes }
      end
      
      trait :cancelled do
        status { :cancelled }
        cancelled_at { Time.current - 5.minutes }
      end
      
      factory :pending_ride, traits: [:pending]
      factory :accepted_ride, traits: [:accepted]
      factory :in_progress_ride, traits: [:in_progress]
      factory :completed_ride, traits: [:completed]
      factory :cancelled_ride, traits: [:cancelled]
    end
  end