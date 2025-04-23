FactoryBot.define do
    factory :location do
      name { Faker::University.name }
      description { Faker::Lorem.sentence }
      latitude { Faker::Address.latitude }
      longitude { Faker::Address.longitude }
      location_type { Location.location_types.keys.sample }
      active { true }
      
      trait :academic_building do
        name { "#{Faker::Educator.course_name} Hall" }
        location_type { :academic_building }
      end
      
      trait :residence_hall do
        name { "#{Faker::Ancient.hero} Hall" }
        location_type { :residence_hall }
      end
      
      trait :parking_lot do
        name { "Parking Lot #{('A'..'Z').to_a.sample}" }
        location_type { :parking_lot }
      end
      
      trait :bus_stop do
        name { "#{Faker::Address.street_name} Bus Stop" }
        location_type { :bus_stop }
      end
      
      factory :academic_building, traits: [:academic_building]
      factory :residence_hall, traits: [:residence_hall]
      factory :parking_lot, traits: [:parking_lot]
      factory :bus_stop, traits: [:bus_stop]
    end
  end