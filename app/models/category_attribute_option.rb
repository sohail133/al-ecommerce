class CategoryAttributeOption < ApplicationRecord
  belongs_to :category_attribute, inverse_of: :category_attribute_options

  validates :value, presence: true, uniqueness: { scope: :category_attribute_id }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :value) }
end
