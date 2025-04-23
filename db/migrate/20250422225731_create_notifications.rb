class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ride_request, null: false, foreign_key: true
      t.integer :notification_type
      t.string :message
      t.boolean :read

      t.timestamps
    end
  end
end
