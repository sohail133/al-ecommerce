class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  before_save :set_price_snapshot

  def subtotal
    price_snapshot * quantity
  end

  private

  def set_price_snapshot
    self.price_snapshot ||= product_variant.price
  end
end
