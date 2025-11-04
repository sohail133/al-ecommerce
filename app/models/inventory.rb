class Inventory < ApplicationRecord
  belongs_to :product_variant

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :threshold_level, presence: true, numericality: { greater_than: 0 }

  scope :low_stock, -> { where("quantity <= threshold_level") }

  def available_quantity
    [quantity - reserved_quantity, 0].max
  end

  def low_stock?
    quantity <= threshold_level
  end

  def in_stock?
    available_quantity > 0
  end

  def can_reserve?(amount)
    available_quantity >= amount
  end
end
