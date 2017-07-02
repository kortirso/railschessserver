# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170702050724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "ais", id: :serial, force: :cascade do |t|
    t.integer "elo", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "challenges", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "opponent_id"
    t.string "color"
    t.boolean "access", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opponent_id"], name: "index_challenges_on_opponent_id"
    t.index ["user_id"], name: "index_challenges_on_user_id"
  end

  create_table "games", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "opponent_id"
    t.boolean "access", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "white_turn", default: true
    t.float "game_result"
    t.string "white_checkmat"
    t.string "black_checkmat"
    t.string "white_beats", default: [], array: true
    t.string "black_beats", default: [], array: true
    t.string "white_protectes", default: [], array: true
    t.string "black_protectes", default: [], array: true
    t.string "w_king_protectors", default: [], array: true
    t.string "b_king_protectors", default: [], array: true
    t.integer "challenge_id"
    t.integer "user_rating"
    t.integer "opponent_rating"
    t.string "guest"
    t.string "possibles", default: [], array: true
    t.integer "offer_draw_by"
    t.integer "ai_id"
    t.hstore "board"
    t.index ["ai_id"], name: "index_games_on_ai_id"
    t.index ["challenge_id"], name: "index_games_on_challenge_id"
    t.index ["opponent_id"], name: "index_games_on_opponent_id"
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "turns", id: :serial, force: :cascade do |t|
    t.integer "game_id"
    t.string "from"
    t.string "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "second_from"
    t.string "second_to"
    t.string "next_turn"
    t.string "icon"
    t.index ["game_id"], name: "index_turns_on_game_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "elo", default: 1000
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

end
