# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_03_21_195556) do
  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "client_type"
    t.string "mail"
    t.string "phone"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.string "city"
    t.string "country"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "organisation_id"
    t.index ["organisation_id"], name: "index_clients_on_organisation_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "date"
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "total_price_ht"
    t.integer "organisation_id"
    t.string "status", default: "brouillon"
    t.integer "payment_terms"
    t.date "payment_due_date"
    t.integer "id_by_org"
    t.index ["client_id"], name: "index_orders_on_client_id"
    t.index ["organisation_id"], name: "index_orders_on_organisation_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "status"
    t.datetime "creation_date"
    t.string "business_name"
    t.string "address"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "city"
    t.string "country"
    t.string "identification_number"
    t.string "vat_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo"
    t.string "capital"
  end

  create_table "prices", force: :cascade do |t|
    t.decimal "amount"
    t.string "currency", default: "Euros"
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_prices_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_image"
    t.integer "organisation_id"
    t.index ["organisation_id"], name: "index_products_on_organisation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firstname"
    t.string "lastname"
    t.integer "organisation_id"
    t.string "phone"
    t.date "birthdate"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "clients", "organisations"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "clients"
  add_foreign_key "orders", "organisations"
  add_foreign_key "orders", "users"
  add_foreign_key "prices", "products"
  add_foreign_key "products", "organisations"
  add_foreign_key "users", "organisations"
end
