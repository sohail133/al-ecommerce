# frozen_string_literal: true

class AddBannerSettingsToStoreSettings < ActiveRecord::Migration[8.0]
  def up
    add_column :store_settings, :banner_enabled, :boolean, default: true, null: false
    add_column :store_settings, :banner_text, :string
    add_column :store_settings, :banner_background_color, :string
    add_column :store_settings, :banner_text_color, :string

    default_text = "Free shipping on selected orders · Cash on Delivery available"
    execute(
      "UPDATE store_settings SET banner_text = #{ActiveRecord::Base.connection.quote(default_text)} " \
      "WHERE banner_text IS NULL OR banner_text = ''"
    )
  end

  def down
    remove_column :store_settings, :banner_enabled
    remove_column :store_settings, :banner_text
    remove_column :store_settings, :banner_background_color
    remove_column :store_settings, :banner_text_color
  end
end
