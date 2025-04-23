# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_23_020307) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "location_type"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "ride_request_id", null: false
    t.integer "notification_type"
    t.string "message"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ride_request_id"], name: "index_notifications_on_ride_request_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "ride_requests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "status"
    t.integer "passengers_count"
    t.text "special_instructions"
    t.datetime "accepted_at"
    t.datetime "pickup_at"
    t.datetime "completed_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pickup_location_id"
    t.integer "dropoff_location_id"
    t.index ["dropoff_location_id"], name: "index_ride_requests_on_dropoff_location_id"
    t.index ["pickup_location_id"], name: "index_ride_requests_on_pickup_location_id"
    t.index ["user_id"], name: "index_ride_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "u_number"
    t.string "phone"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "notifications", "ride_requests"
  add_foreign_key "notifications", "users"
  add_foreign_key "ride_requests", "locations", column: "dropoff_location_id"
  add_foreign_key "ride_requests", "locations", column: "pickup_location_id"
  add_foreign_key "ride_requests", "users"
end
