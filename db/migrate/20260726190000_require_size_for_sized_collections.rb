# frozen_string_literal: true

# Rings and bangles cannot be shipped without a size, so the collections that need
# sizing are flagged here and enforced on ProductVariant.

class RequireSizeForSizedCollections < ActiveRecord::Migration[8.0]
  def up
    add_column :subcategories, :size_required, :boolean, default: false, null: false

    jewelry = Category.find_by(name: "Jewelry")
    return unless jewelry

    bangle_size = jewelry.category_attributes.find_or_initialize_by(slug: "bangle-size")
    bangle_size.name = "Bangle Size"
    bangle_size.input_type = "select"
    bangle_size.required = false
    bangle_size.position = 1
    bangle_size.save!

    ["2.2", "2.4", "2.6", "2.8", "2.10"].each_with_index do |value, index|
      option = bangle_size.category_attribute_options.find_or_initialize_by(value: value)
      option.position = index
      option.save!
    end

    jewelry.category_attributes.where(slug: "color").update_all(position: 2)

    Subcategory.where(category_id: jewelry.id, name: ["Rings", "Bangles"]).update_all(size_required: true)
  end

  def down
    remove_column :subcategories, :size_required
  end
end
