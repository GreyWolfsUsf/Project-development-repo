class CreateUsers < ActiveRecord::Migration[7.0]
    def change
      create_table :users do |t|
        t.string :email, null: false
        t.string :password_digest, null: false
        t.string :first_name, null: false
        t.string :last_name, null: false
        t.string :u_number, null: false  # USF student ID (U12345678)
        t.string :phone
        t.integer :role, default: 0  # 0: student, 1: driver, 2: admin
        t.datetime :last_login_at
  
        t.timestamps
      end
      
      add_index :users, :email, unique: true
      add_index :users, :u_number, unique: true
    end
  end