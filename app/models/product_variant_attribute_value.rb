class ProductVariantAttributeValue < ApplicationRecord
  belongs_to :product_variant, inverse_of: :attribute_values
  belongs_to :category_attribute

  validates :value, presence: true
  validates :category_attribute_id, uniqueness: { scope: :product_variant_id }
  validate :attribute_belongs_to_product_category

  private

  def attribute_belongs_to_product_category
    return if product_variant.blank? || category_attribute.blank? || product_variant.product.blank?

    unless category_attribute.category_id == product_variant.product.category_id
      errors.add(:category_attribute, "does not belong to this product's category")
    end
  end
end
