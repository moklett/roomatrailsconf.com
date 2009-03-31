# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090328154627) do

  create_table "tweets", :force => true do |t|
    t.boolean  "truncated"
    t.boolean  "favorited"
    t.text     "text"
    t.integer  "twitter_id"
    t.integer  "in_reply_to_status_id"
    t.integer  "in_reply_to_user_id"
    t.string   "source"
    t.datetime "timestamp"
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "user_screen_name"
    t.string   "user_profile_image_url"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tweets", ["twitter_id"], :name => "index_tweets_on_twitter_id", :unique => true

  create_table "users", :force => true do |t|
    t.integer  "twitter_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.text     "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.integer  "followers_count"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["screen_name"], :name => "index_users_on_screen_name", :unique => true
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id", :unique => true

end
