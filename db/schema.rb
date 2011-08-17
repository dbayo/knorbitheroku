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

ActiveRecord::Schema.define(:version => 20110620084337) do

  create_table "accounts", :force => true do |t|
    t.string   "organization"
    t.string   "phone"
    t.string   "post_address"
    t.text     "language"
    t.text     "geospace"
    t.integer  "credit"
    t.integer  "reputation"
    t.string   "account"
    t.string   "userlevel"
    t.string   "active"
    t.integer  "maxinv"
    t.string   "allowsms"
    t.string   "allowalerts"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "delicious"
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.integer  "code"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["job_id"], :name => "index_activities_on_job_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "comments", :force => true do |t|
    t.string   "comment"
    t.integer  "user_id"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contributions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contributions", ["user_id", "job_id"], :name => "index_contributions_on_user_id_and_job_id", :unique => true

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.string   "status"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followers", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.string   "group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followers", ["followed_id"], :name => "index_followers_on_followed_id"
  add_index "followers", ["follower_id", "followed_id"], :name => "index_followers_on_follower_id_and_followed_id", :unique => true
  add_index "followers", ["follower_id"], :name => "index_followers_on_follower_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name", "user_id"], :name => "index_groups_on_name_and_user_id", :unique => true

  create_table "invitations", :force => true do |t|
    t.integer  "from_id"
    t.string   "to_email"
    t.integer  "job_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "wiki"
    t.string   "wikispace"
    t.text     "language"
    t.string   "public"
    t.string   "viral"
    t.string   "smart"
    t.string   "favorite"
    t.string   "recomendations"
    t.date     "date"
    t.integer  "duration"
    t.integer  "maxcontributors"
    t.text     "countriesexcluded"
    t.text     "template"
    t.string   "status"
    t.string   "keyword1"
    t.string   "keyword2"
    t.string   "keyword3"
    t.string   "keyword4"
    t.string   "keyword5"
    t.text     "qualifier1"
    t.text     "qualifier2"
    t.text     "qualifier3"
    t.text     "qualifier4"
    t.text     "qualifier5"
    t.string   "checkmarkskills"
    t.string   "checkmarksections"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["name", "user_id"], :name => "index_jobs_on_name_and_user_id", :unique => true
  add_index "jobs", ["user_id"], :name => "index_jobs_on_user_id"

  create_table "jobversions", :force => true do |t|
    t.integer  "job_id"
    t.integer  "user_id"
    t.string   "version_name"
    t.string   "version_wiki"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "subject"
    t.text     "body"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["from_id"], :name => "index_messages_on_from_id"
  add_index "messages", ["to_id"], :name => "index_messages_on_to_id"

  create_table "monkeys", :force => true do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.text     "keyword1"
    t.text     "keyword2"
    t.text     "keyword3"
    t.text     "keyword4"
    t.text     "keyword5"
    t.text     "qualifier1"
    t.text     "qualifier2"
    t.text     "qualifier3"
    t.text     "qualifier4"
    t.text     "qualifier5"
    t.text     "oftentags"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "rewards", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "contributor_id"
    t.integer  "job_id"
    t.integer  "points"
    t.integer  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sharedjobs", :force => true do |t|
    t.integer  "from_id"
    t.string   "to_email"
    t.integer  "job_id"
    t.string   "method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sharedjobs", ["job_id"], :name => "index_sharedjobs_on_job_id"

  create_table "spaces", :force => true do |t|
    t.string   "wiki_name"
    t.string   "name"
    t.string   "status"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spaces", ["name"], :name => "index_spaces_on_name"

  create_table "spaceversions", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "space_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submittedinvitations", :force => true do |t|
    t.integer  "from_id"
    t.string   "to_email"
    t.integer  "job_id"
    t.string   "status"
    t.string   "method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "frequency"
    t.text     "related"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "version"
    t.text     "content"
    t.integer  "document_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["version"], :name => "index_versions_on_version", :unique => true

end
