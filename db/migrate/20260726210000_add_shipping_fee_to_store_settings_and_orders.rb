# frozen_string_literal: true

class AddShippingFeeToStoreSettingsAndOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :store_settings, :shipping_fee, :decimal, precision: 10, scale: 2, default: 0, null: false
    add_column :orders, :shipping_fee, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
