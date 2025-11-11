class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def total
    cart_items.sum { |item| item.price_snapshot * item.quantity }
  end

  def items_count
    cart_items.sum(:quantity)
  end
end
