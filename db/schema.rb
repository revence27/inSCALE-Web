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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130710143634) do

  create_table "admin_addresses", :force => true do |t|
    t.text     "address"
    t.text     "name"
    t.datetime "latest"
    t.boolean  "biostat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "applications", :force => true do |t|
    t.text     "name"
    t.text     "description"
    t.text     "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "publisher_id"
    t.integer  "client_id"
  end

  create_table "binaries", :force => true do |t|
    t.text     "jar_b64"
    t.text     "jar_sha1"
    t.text     "release_note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  create_table "bio_stats", :force => true do |t|
    t.text     "name"
    t.text     "sha1_pass"
    t.text     "sha1_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bug_reports", :force => true do |t|
    t.text     "description"
    t.text     "contact"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", :force => true do |t|
    t.text     "name"
    t.text     "code"
    t.text     "sha1_pass"
    t.text     "sha1_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collected_infos", :force => true do |t|
    t.datetime "time_sent"
    t.string   "vht_code"
    t.integer  "male_children"
    t.integer  "female_children"
    t.integer  "positive_rdt"
    t.integer  "negative_rdt"
    t.integer  "diarrhoea"
    t.integer  "fast_breathing"
    t.integer  "fever"
    t.integer  "danger_sign"
    t.integer  "treated_within_24_hrs"
    t.integer  "treated_with_ors"
    t.integer  "treated_with_zinc12"
    t.integer  "treated_with_zinc1"
    t.integer  "treated_with_amoxi_red"
    t.integer  "treated_with_amoxi_green"
    t.integer  "treated_with_coartem_yellow"
    t.integer  "treated_with_coartem_blue"
    t.integer  "treated_with_rectal_artus_1"
    t.integer  "treated_with_rectal_artus_2"
    t.integer  "treated_with_rectal_artus_4"
    t.integer  "referred"
    t.integer  "died"
    t.integer  "male_newborns"
    t.integer  "female_newborns"
    t.integer  "home_visits_day_1"
    t.integer  "home_visits_day_3"
    t.integer  "home_visits_day_7"
    t.integer  "newborns_with_danger_sign"
    t.integer  "newborns_referred"
    t.integer  "newborns_yellow_MUAC"
    t.integer  "newborns_red_MUAC"
    t.integer  "ors_balance"
    t.integer  "zinc_balance"
    t.integer  "yellow_ACT_balance"
    t.integer  "blue_ACT_balance"
    t.integer  "red_amoxi_balance"
    t.integer  "green_amoxi_balance"
    t.integer  "rdt_balance"
    t.integer  "rectal_artus_balance"
    t.boolean  "gloves_left_mt5"
    t.boolean  "muac_tape"
    t.integer  "submission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "districts", :force => true do |t|
    t.text  "name"
    t.float "xpos"
    t.float "ypos"
  end

  create_table "feedbacks", :force => true do |t|
    t.text     "message"
    t.text     "number"
    t.text     "sender"
    t.datetime "sent_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "system_response"
    t.text     "tag",             :default => "routine", :null => false
  end

  create_table "jad_fields", :force => true do |t|
    t.text     "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "binary_id"
  end

  create_table "locations", :force => true do |t|
    t.float "xcoord"
    t.float "ycoord"
    t.text  "name"
  end

  create_table "missed_codes", :force => true do |t|
    t.text     "pdu"
    t.text     "url"
    t.text     "tentative_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "motivational_messages", :force => true do |t|
    t.integer  "month"
    t.text     "english"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parishes", :force => true do |t|
    t.text  "name"
    t.float "xpos"
    t.float "ypos"
  end

  create_table "periodic_tasks", :force => true do |t|
    t.text     "task_name"
    t.text     "identity"
    t.text     "running_url"
    t.datetime "last_successful"
    t.integer  "seconds_period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publishers", :force => true do |t|
    t.text     "name"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "root_accounts", :force => true do |t|
    t.text     "sha1_pass"
    t.text     "sha1_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submission_errors", :force => true do |t|
    t.text     "pdu"
    t.text     "message"
    t.text     "backtrace"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", :force => true do |t|
    t.text     "pdu"
    t.text     "number"
    t.datetime "actual_time"
    t.integer  "system_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supervisors", :force => true do |t|
    t.text     "name"
    t.text     "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "parish_id"
  end

  create_table "system_users", :force => true do |t|
    t.text     "name"
    t.text     "number"
    t.text     "code"
    t.integer  "client_id"
    t.integer  "supervisor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parish_id"
    t.integer  "village_id"
    t.integer  "district_id"
    t.integer  "sort_code",     :default => 0, :null => false
    t.text     "latest_client"
  end

  create_table "user_tags", :force => true do |t|
    t.text     "name"
    t.integer  "system_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vht_responses", :force => true do |t|
    t.integer  "week"
    t.text     "many_kids"
    t.text     "no_kids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "villages", :force => true do |t|
    t.text  "name"
    t.float "xpos"
    t.float "ypos"
  end

end
