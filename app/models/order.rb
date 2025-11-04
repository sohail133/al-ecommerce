class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address
  belongs_to :payment_method
  has_many :order_items, dependent: :destroy

  enum :status, {
    pending: 0,
    accepted: 1,
    processing: 2,
    shipped: 3,
    delivered: 4,
    canceled: 5
  }

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :user_id, presence: true
  validates :address_id, presence: true
  validates :payment_method_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  before_validation :calculate_total, on: :create

  def can_cancel?
    pending? || accepted?
  end

  def can_update_status?
    !delivered? && !canceled?
  end

  def items_count
    order_items.sum(:quantity)
  end

  private

  def calculate_total
    self.total_amount = order_items.sum(&:subtotal) if order_items.any?
  end
end
