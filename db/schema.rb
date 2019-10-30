# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_28_182407) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "genres", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "netflix_genre_id"
    t.string "genre_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["movie_id"], name: "index_genres_on_movie_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.string "director"
    t.string "plot"
    t.text "actors"
    t.string "photo"
    t.float "imdb_score"
    t.boolean "brazil"
    t.boolean "us"
    t.boolean "portugal"
    t.boolean "germany"
    t.boolean "sweden"
    t.boolean "france"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.string "netflix_id"
    t.string "runtime"
    t.string "writer"
    t.boolean "omdb"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "watchlists", force: :cascade do |t|
    t.bigint "movie_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_watchlists_on_movie_id"
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "genres", "movies"
  add_foreign_key "watchlists", "movies"
  add_foreign_key "watchlists", "users"
end
