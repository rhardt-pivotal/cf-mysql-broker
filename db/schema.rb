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

ActiveRecord::Schema.define(version: 2018_01_17_002358) do

  create_table "read_only_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "username"
    t.string "grantee"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grantee"], name: "index_read_only_users_on_grantee"
    t.index ["username"], name: "index_read_only_users_on_username"
  end

  create_table "service_instances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "guid"
    t.string "plan_guid"
    t.integer "max_storage_mb", default: 0, null: false
    t.string "db_name"
    t.index ["db_name"], name: "index_service_instances_on_db_name"
    t.index ["guid"], name: "index_service_instances_on_guid"
    t.index ["plan_guid"], name: "index_service_instances_on_plan_guid"
  end

end
