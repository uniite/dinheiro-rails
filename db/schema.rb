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

ActiveRecord::Schema.define(version: 20130928021014) do

  create_table "accounts", force: true do |t|
    t.integer  "institution_id"
    t.string   "account_number"
    t.string   "name"
    t.string   "routing_number"
    t.decimal  "balance",        precision: 15, scale: 2
    t.string   "ofx_broker"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institutions", force: true do |t|
    t.integer  "user_id"
    t.integer  "ofx_fid"
    t.string   "ofx_org"
    t.string   "url"
    t.string   "username"
    t.string   "password"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", force: true do |t|
    t.string   "operator"
    t.string   "field"
    t.string   "content"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", force: true do |t|
    t.integer  "account_id"
    t.string   "currency"
    t.datetime "date"
    t.decimal  "amount",          precision: 15, scale: 2
    t.string   "payee"
    t.string   "ofx_transaction"
    t.string   "type"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
