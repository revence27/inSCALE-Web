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

ActiveRecord::Schema.define(:version => 20111030163431) do

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

  create_table "clients", :force => true do |t|
    t.text     "name"
    t.text     "code"
    t.text     "sha1_pass"
    t.text     "sha1_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jad_fields", :force => true do |t|
    t.text     "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "binary_id"
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

  create_table "submissions", :force => true do |t|
    t.text     "pdu"
    t.text     "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
