# frozen_string_literal: true

# Align Jewelry category with artificial / fashion jewelry (AK Collections style):
# shoppers pick Ring Size and/or Color only — not karat, stone, or weight.

class AlignJewelryForArtificialBusiness < ActiveRecord::Migration[8.0]
  def up
    jewelry = Category.find_by(name: "Jewelry")
    return unless jewelry

    jewelry.update!(
      description: "Artificial jewelry — waterproof, anti-tarnish fashion pieces for everyday wear"
    )

    obsolete = jewelry.category_attributes.where(name: %w[Material Karat Stone Weight])
    obsolete.find_each(&:destroy)

    ensure_attribute!(
      jewelry,
      name: "Ring Size",
      input_type: "select",
      required: false,
      position: 0,
      options: %w[6 7 8 9 10 11 12 Adjustable]
    )

    ensure_attribute!(
      jewelry,
      name: "Color",
      input_type: "select",
      required: false,
      position: 1,
      options: ["Gold", "Silver", "Rose Gold", "Black", "White"]
    )

    # Extra collections used by fashion jewelry stores
    ["Bangles", "Anklets", "Locket Sets"].each do |name|
      Subcategory.find_or_create_by!(category: jewelry, name: name)
    end
  end

  def down
    # Irreversible data cleanup — attributes were removed intentionally.
  end

  private

  def ensure_attribute!(category, name:, input_type:, required:, position:, options:)
    attribute = category.category_attributes.find_or_initialize_by(slug: name.parameterize)
    attribute.name = name
    attribute.input_type = input_type
    attribute.required = required
    attribute.position = position
    attribute.save!

    options.each_with_index do |value, index|
      option = attribute.category_attribute_options.find_or_initialize_by(value: value)
      option.position = index
      option.save!
    end

    # Drop leftover options that no longer apply (e.g. old ring size 14/16/18)
    attribute.category_attribute_options.where.not(value: options).destroy_all
  end
end
