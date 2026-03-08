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

ActiveRecord::Schema[8.1].define(version: 2026_03_09_014001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "crm_deals", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.date "close_date"
    t.datetime "created_at", null: false
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_crm_deals_on_user_id"
  end

  create_table "email_messages", force: :cascade do |t|
    t.text "body_text"
    t.datetime "created_at", null: false
    t.datetime "date"
    t.bigint "email_thread_id", null: false
    t.string "google_id"
    t.jsonb "payload"
    t.string "recipient"
    t.string "sender"
    t.datetime "updated_at", null: false
    t.index ["email_thread_id"], name: "index_email_messages_on_email_thread_id"
    t.index ["google_id"], name: "index_email_messages_on_google_id", unique: true
  end

  create_table "email_threads", force: :cascade do |t|
    t.boolean "action_completed"
    t.string "action_description"
    t.string "classification"
    t.datetime "created_at", null: false
    t.text "draft_reply"
    t.string "google_id"
    t.string "history_id"
    t.bigint "oauth_connection_id", null: false
    t.string "snippet"
    t.string "status"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["google_id"], name: "index_email_threads_on_google_id", unique: true
    t.index ["oauth_connection_id"], name: "index_email_threads_on_oauth_connection_id"
  end

  create_table "oauth_connections", force: :cascade do |t|
    t.text "access_token"
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.string "image_url"
    t.string "name"
    t.string "provider", null: false
    t.text "refresh_token"
    t.text "scopes"
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["provider", "uid"], name: "index_oauth_connections_on_provider_and_uid", unique: true
    t.index ["user_id", "provider", "active"], name: "index_oauth_connections_on_user_id_and_provider_and_active"
    t.index ["user_id"], name: "index_oauth_connections_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin"
    t.string "background_image_url"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "crm_deals", "users"
  add_foreign_key "email_messages", "email_threads"
  add_foreign_key "email_threads", "oauth_connections"
  add_foreign_key "oauth_connections", "users"
end
