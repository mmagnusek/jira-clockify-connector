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

ActiveRecord::Schema.define(version: 2020_10_26_133754) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "time_entries", force: :cascade do |t|
    t.bigint "user_id"
    t.string "clockify_id"
    t.string "clockify_description"
    t.integer "jira_id"
    t.string "jira_task_id"
    t.string "jira_task_description"
    t.datetime "start_time"
    t.bigint "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "synced_at"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "clockify_id"
    t.string "jira_username"
    t.string "jira_password"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
