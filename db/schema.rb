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

ActiveRecord::Schema.define(:version => 20100112041255) do

  create_table "attachments", :force => true do |t|
    t.integer  "item_id"
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "avatar_files", :force => true do |t|
    t.binary "data"
  end

  create_table "avatars", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.integer  "db_file_id"
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.integer  "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blobs", :force => true do |t|
    t.binary   "content",    :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cloud_tools", :force => true do |t|
    t.text     "name"
    t.integer  "info_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "score"
    t.integer  "creator_id"
    t.integer  "info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_types", :force => true do |t|
    t.text     "name",         :limit => 255
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "display_topics", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "referer_id"
    t.integer  "verifier_id"
    t.boolean  "status"
    t.integer  "display_type"
    t.integer  "region_id"
    t.date     "from"
    t.date     "to"
    t.integer  "order_id",     :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fee_records", :force => true do |t|
    t.integer  "user_id"
    t.integer  "fee"
    t.string   "month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "topic_id"
    t.integer  "verified",     :limit => 1
    t.integer  "creator_id"
    t.integer  "affirmant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "functions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "info_counters", :force => true do |t|
    t.integer  "info_id"
    t.integer  "comment_count"
    t.integer  "view_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "info_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "cloud_tool_name"
    t.boolean  "status"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "infos", :force => true do |t|
    t.integer  "info_type_id"
    t.boolean  "if_commented"
    t.integer  "creator_id"
    t.integer  "comments_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_types", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "info_type_id"
    t.integer  "content_type_id"
    t.boolean  "if_permit_extra_condition", :default => false
    t.boolean  "if_title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "item_type_id"
    t.integer  "info_id"
    t.boolean  "if_attachment"
    t.string   "value",                           :default => ""
    t.integer  "extra_condition_id", :limit => 1, :default => 0
    t.integer  "content_type_id"
    t.boolean  "if_title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maintainings", :force => true do |t|
    t.integer  "maintainer_id"
    t.integer  "topic_id"
    t.integer  "verified"
    t.integer  "creator_id"
    t.integer  "affirmant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "markers", :force => true do |t|
    t.decimal  "lat",                       :precision => 15, :scale => 10
    t.decimal  "lng",                       :precision => 15, :scale => 10
    t.string   "found",      :limit => 100
    t.string   "left",       :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "name",           :limit => 10
    t.string   "image_file"
    t.string   "image_file_url"
    t.integer  "item_id"
    t.boolean  "is_avatar"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "real_users", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "id_card_number"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommended_topics", :force => true do |t|
    t.integer  "topic_id",   :null => false
    t.integer  "referer_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.integer  "parent_region_id"
    t.integer  "status"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "rank"
    t.integer  "creator_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "team_topics", :force => true do |t|
    t.integer  "team_id"
    t.integer  "topic_id"
    t.integer  "operation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_users", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.integer  "status",       :limit => 1
    t.integer  "creator_id"
    t.integer  "affirmant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_counters", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "following_count", :default => 0
    t.integer  "view_count",      :default => 0
    t.integer  "info_count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_counters", ["topic_id"], :name => "topic_id", :unique => true

  create_table "topic_info_types", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "info_type_id"
    t.integer  "display_order_in_topic"
    t.string   "display_name_in_topic",  :limit => 40, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_infos", :force => true do |t|
    t.integer  "info_id"
    t.integer  "topic_id"
    t.boolean  "verified"
    t.integer  "creator_id"
    t.integer  "affirmant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_statistics", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "infos_quantity",            :default => 0
    t.integer  "my_infos_quantity",         :default => 0
    t.integer  "other_infos_quantity",      :default => 0
    t.integer  "follow_me_user_quantity",   :default => 0
    t.integer  "maintain_me_user_quantity", :default => 0
    t.integer  "comment_quantity",          :default => 0
    t.integer  "visit_quantity",            :default => 0
    t.integer  "click_info_quantity",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_types", :force => true do |t|
    t.string   "name"
    t.integer  "parent_topic_type_id"
    t.integer  "status"
    t.integer  "creator_id"
    t.integer  "verifier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "status",           :limit => 1
    t.boolean  "if_verify_info"
    t.integer  "following_mode",   :limit => 1
    t.integer  "maintaining_mode", :limit => 1
    t.integer  "followings_count"
    t.integer  "creator_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["title"], :name => "TOPIC_TITLE", :unique => true

  create_table "user_functions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "function_id"
    t.boolean  "status"
    t.datetime "up_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_geo_positions", :force => true do |t|
    t.integer  "user_id"
    t.float    "latitude",   :limit => 20
    t.float    "longitude",  :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_info_types", :force => true do |t|
    t.integer  "user_id"
    t.integer  "info_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_item_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.integer  "payment_status"
    t.string   "password"
    t.integer  "counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "region_id"
    t.float    "latitude",                  :limit => 20
    t.float    "longitude",                 :limit => 20
  end

end
