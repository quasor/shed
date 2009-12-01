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

ActiveRecord::Schema.define(:version => 20091201044305) do

  create_table "holidays", :force => true do |t|
    t.date     "holiday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "intervals", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "user_id"
    t.integer  "task_id"
    t.integer  "hours",      :limit => 10, :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "intervals", ["task_id"], :name => "index_intervals_on_task_id"

  create_table "projections", :force => true do |t|
    t.integer  "task_id"
    t.date     "start"
    t.date     "end"
    t.integer  "confidence",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "simulation_id"
  end

  add_index "projections", ["task_id"], :name => "index_projections_on_task_id"

  create_table "simulations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "task_versions", :force => true do |t|
    t.integer  "task_id"
    t.integer  "version"
    t.string   "title"
    t.text     "description"
    t.float    "low_estimate_cache"
    t.float    "high_estimate_cache"
    t.boolean  "completed",                        :default => false
    t.integer  "user_id",             :limit => 8
    t.datetime "start"
    t.integer  "parent_id",           :limit => 8
    t.integer  "lft",                 :limit => 8
    t.integer  "rgt",                 :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_tag_list"
    t.date     "due"
    t.datetime "end"
    t.string   "estimate"
    t.date     "best_start"
    t.date     "worst_start"
    t.date     "best_end"
    t.date     "worst_end"
    t.integer  "position",            :limit => 8
    t.boolean  "on_hold",                          :default => false
    t.string   "versioned_type"
  end

  create_table "tasks", :force => true do |t|
    t.string   "title"
    t.string   "type"
    t.text     "description"
    t.float    "low_estimate_cache"
    t.float    "high_estimate_cache"
    t.boolean  "completed",           :default => false
    t.integer  "user_id"
    t.datetime "start"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_tag_list"
    t.date     "due"
    t.datetime "end"
    t.string   "estimate"
    t.date     "best_start"
    t.date     "worst_start"
    t.date     "best_end"
    t.date     "worst_end"
    t.integer  "position"
    t.boolean  "on_hold",             :default => false
    t.integer  "version"
    t.float    "start_in_days",       :default => 0.0
    t.float    "end_in_days",         :default => 0.0
  end

  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.float    "efficiency", :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "loginkey"
    t.integer  "team_id"
  end

end
