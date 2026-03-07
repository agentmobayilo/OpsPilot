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

ActiveRecord::Schema[8.1].define(version: 2026_03_07_005346) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.index ["user_id", "provider"], name: "index_oauth_connections_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_oauth_connections_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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

  add_foreign_key "oauth_connections", "users"
end
