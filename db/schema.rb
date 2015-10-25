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

ActiveRecord::Schema.define(version: 20150904161019) do

  create_table "deployments", force: :cascade do |t|
    t.text     "custom_payload"
    t.string   "guid"
    t.string   "name"
    t.string   "name_with_owner"
    t.string   "output"
    t.string   "ref"
    t.string   "sha"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repository_id"
    t.integer  "environment_id",  null: false
    t.string   "sender"
    t.string   "avatar_url"
  end

  add_index "deployments", ["created_at"], name: "index_deployments_on_created_at"
  add_index "deployments", ["name", "environment_id", "name_with_owner"], name: "index_deployments_on_latest_for_name_with_owner"
  add_index "deployments", ["repository_id", "environment_id"], name: "index_deployments_on_repository_id_and_environment_id"

  create_table "environments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "environments", ["name"], name: "index_environments_on_name"

  create_table "repositories", force: :cascade do |t|
    t.string   "owner"
    t.string   "name"
    t.boolean  "active",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repositories", ["owner", "name"], name: "index_repositories_on_owner_and_name", unique: true

end
