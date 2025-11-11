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

ActiveRecord::Schema[8.1].define(version: 2025_11_11_132530) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "full_name"
    t.boolean "is_default", default: false
    t.string "phone_number"
    t.string "postal_code"
    t.string "province"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.decimal "price_snapshot", precision: 10, scale: 2
    t.bigint "product_variant_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_variant_id"], name: "index_cart_items_on_cart_id_and_product_variant_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "contact_us", force: :cascade do |t|
    t.text "admin_response"
    t.datetime "created_at", null: false
    t.string "email"
    t.text "message"
    t.string "name"
    t.datetime "replied_at"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["user_id", "product_id"], name: "index_favorites_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "hero_images", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position", default: 0
    t.text "subtitle"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "inventories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.integer "quantity", default: 0
    t.integer "reserved_quantity", default: 0
    t.integer "threshold_level", default: 10
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_inventories_on_product_variant_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.decimal "price", precision: 10, scale: 2
    t.bigint "product_variant_id", null: false
    t.integer "quantity"
    t.decimal "subtotal", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "address_id", null: false
    t.datetime "created_at", null: false
    t.bigint "payment_method_id", null: false
    t.integer "status", default: 0
    t.decimal "total_amount", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["payment_method_id"], name: "index_orders_on_payment_method_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "product_variants", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.bigint "product_id", null: false
    t.string "sku"
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.string "slug"
    t.bigint "subcategory_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["subcategory_id"], name: "index_products_on_subcategory_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.bigint "order_item_id", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["order_item_id", "user_id"], name: "index_reviews_on_order_item_id_and_user_id"
    t.index ["order_item_id"], name: "index_reviews_on_order_item_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "store_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "facebook_url"
    t.string "instagram_url"
    t.text "location"
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.string "youtube_url"
  end

  create_table "subcategories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_subcategories_on_category_id"
    t.index ["slug"], name: "index_subcategories_on_slug", unique: true
  end

  create_table "subscribers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "status", default: "active", null: false
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscribers_on_email", unique: true
    t.index ["status"], name: "index_subscribers_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 1
    t.boolean "status", default: true
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "carts", "users"
  add_foreign_key "favorites", "products"
  add_foreign_key "favorites", "users"
  add_foreign_key "inventories", "product_variants"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "payment_methods"
  add_foreign_key "orders", "users"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "subcategories"
  add_foreign_key "reviews", "order_items"
  add_foreign_key "reviews", "users"
  add_foreign_key "subcategories", "categories"
end
