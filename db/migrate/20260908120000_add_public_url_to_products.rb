# frozen_string_literal: true

class AddPublicUrlToProducts < ActiveRecord::Migration[8.0]
  def up
    add_column :products, :public_url, :string

    Product.reset_column_information

    base = Site.url
    Product.find_each do |product|
      next if product.slug.blank?

      product.update_column(:public_url, "#{base}/products/#{product.slug}")
    end
  end

  def down
    remove_column :products, :public_url
  end
end
