# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160605205043) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "state",                                  null: false
    t.boolean  "agreement_coc",          default: false, null: false
    t.boolean  "agreement_attendance",   default: false, null: false
    t.boolean  "agreement_deadline",     default: false, null: false
    t.datetime "submitted_at"
    t.datetime "processed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "why_andconf"
    t.text     "feminism"
    t.text     "programming_experience"
    t.text     "diversity"
    t.datetime "confirmed_at"
    t.text     "scholarship"
    t.text     "travel_stipend"
    t.boolean  "attend_last_year"
    t.text     "referral_code"
    t.text     "stipend_request"
  end

  add_index "applications", ["state"], name: "index_applications_on_state", using: :btree
  add_index "applications", ["user_id"], name: "index_applications_on_user_id", using: :btree

  create_table "attendances", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "badge_name"
    t.text     "dietary_restrictions"
    t.text     "dietary_additional_info"
    t.text     "twitter_handle"
    t.text     "sleeping_preference"
    t.text     "staying_sunday_night"
    t.text     "flying_in"
    t.boolean  "agree_to_coc"
    t.boolean  "attend_entire_conference"
    t.boolean  "interested_in_volunteering"
    t.text     "transport_to_venue"
    t.text     "transport_from_venue"
    t.boolean  "accept_trails_and_pool_risk"
    t.text     "pronouns"
    t.integer  "event_id"
    t.text     "roommate_request"
  end

  add_index "attendances", ["event_id", "user_id"], name: "index_attendances_on_event_id_and_user_id", unique: true, using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.integer  "application_id",              null: false
    t.string   "body",           limit: 2000, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "configurables", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configurables", ["name"], name: "index_configurables_on_name", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["name"], name: "index_events_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "state",                                        null: false
    t.datetime "last_logged_in_at"
    t.string   "email_for_google"
    t.integer  "dues_pledge"
    t.boolean  "is_admin",                     default: false
    t.boolean  "setup_complete"
    t.text     "membership_note"
    t.string   "stripe_customer_id"
    t.datetime "last_stripe_charge_succeeded"
    t.boolean  "is_scholarship",               default: false
    t.boolean  "voting_policy_agreement",      default: false
    t.text     "gender"
    t.string   "travel_stipend"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "application_id", null: false
    t.boolean  "value",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["application_id"], name: "index_votes_on_application_id", using: :btree
  add_index "votes", ["user_id", "application_id"], name: "index_votes_on_user_id_and_application_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
