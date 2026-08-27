# frozen_string_literal: true

class AddWhatsappNumberToStoreSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :store_settings, :whatsapp_number, :string
  end
end
