class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant
  has_many :reviews, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :subtotal, presence: true, numericality: { greater_than: 0 }

  before_validation :calculate_subtotal

  def calculate_subtotal
    self.subtotal = (price * quantity).round(2) if price.present? && quantity.present?
  end
end
