class Review < ApplicationRecord
  belongs_to :order_item
  belongs_to :user

  has_many_attached :images

  validates :rating, presence: true, numericality: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10 }

  scope :recent, -> { order(created_at: :desc) }
  
  delegate :order, to: :order_item
  delegate :product_variant, to: :order_item
  delegate :product, to: :product_variant
end
