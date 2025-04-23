class CreateNotifications < ActiveRecord::Migration[7.0]
    def change
      create_table :notifications do |t|
        t.references :user, null: false, foreign_key: true
        t.references :ride_request, foreign_key: true
        t.integer :notification_type, null: false
        t.string :message, null: false
        t.boolean :read, default: false
        
        t.timestamps
      end

      add_index :notifications, [:user_id, :read]
    end
  end
# db/seeds.rb

# Create USF locations
locations = [
  # Academic buildings
  {name: 'Cooper Hall (CPR)', latitude: 28.062010, longitude: -82.414080, location_type: 0},
  {name: 'Library (LIB)', latitude: 28.059744, longitude: -82.412778, location_type: 0},
  {name: 'Marshall Student Center (MSC)', latitude: 28.064182, longitude: -82.413515, location_type: 0},
  
  # Residence halls
  {name: 'Juniper-Poplar Hall (JPH)', latitude: 28.065356, longitude: -82.417693, location_type: 1},
  {name: 'Castor Hall', latitude: 28.066982, longitude: -82.410673, location_type: 1},
  {name: 'Holly Apartments', latitude: 28.068808, longitude: -82.413076, location_type: 1},
  
  # Parking lots
  {name: 'Parking Lot 1', latitude: 28.067748, longitude: -82.419079, location_type: 2},
  {name: 'Parking Lot 5', latitude: 28.061246, longitude: -82.415805, location_type: 2},
  {name: 'Collins Parking Garage', latitude: 28.061048, longitude: -82.410913, location_type: 2}
]

locations.each do |location_attrs|
  Location.create!(location_attrs)
end

puts "Added #{Location.count} locations"

# In db/seeds.rb
# Add drivers with default avatars
5.times do |i|
  driver = User.create!(
    email: "driver#{i+1}@usf.edu",
    password: 'password',
    first_name: ["Michael", "Sarah", "David", "Emily", "Jason", "Sophia", "Daniel", "Olivia", "James", "Emma"].sample,
    last_name: ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"].sample,
    u_number: "U#{20000000 + i}",
    role: :driver,
    phone: "(813) #{rand(100..999)}-#{rand(1000..9999)}"
  )
  
  # Attach a default avatar (you would need to have these files in your project)
driver.avatar.attach(io: File.open(Rails.root.join('app/assets/images/default_avatars', "driver#{i+1}.jpg")), filename: "driver#{i+1}.jpg")
end