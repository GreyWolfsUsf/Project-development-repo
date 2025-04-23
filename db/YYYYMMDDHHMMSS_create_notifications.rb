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