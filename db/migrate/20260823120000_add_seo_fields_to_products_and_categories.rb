# frozen_string_literal: true

class AddSeoFieldsToProductsAndCategories < ActiveRecord::Migration[8.0]
  def up
    add_column :products, :seo_title, :string
    add_column :products, :seo_description, :text
    add_column :categories, :seo_title, :string
    add_column :categories, :seo_description, :text

    # Backfill from existing content so pages already have usable meta text.
    Product.reset_column_information
    Category.reset_column_information

    Product.find_each do |product|
      title = "#{product.title} | Mahnira".truncate(60, omission: "")
      description = (
        product.description.presence ||
        "Buy #{product.title} online at Mahnira. Quality products with convenient shopping across Pakistan."
      ).to_s.squish.truncate(160, omission: "…")

      product.update_columns(seo_title: title, seo_description: description)
    end

    Category.find_each do |category|
      title = "#{category.name} | Shop #{category.name} Online | Mahnira".truncate(60, omission: "")
      description = (
        category.description.presence ||
        "Shop #{category.name} online at Mahnira. Browse quality products with convenient delivery across Pakistan."
      ).to_s.squish.truncate(160, omission: "…")

      category.update_columns(seo_title: title, seo_description: description)
    end
  end

  def down
    remove_column :products, :seo_title
    remove_column :products, :seo_description
    remove_column :categories, :seo_title
    remove_column :categories, :seo_description
  end
end
