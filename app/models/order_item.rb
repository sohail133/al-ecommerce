class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant
  has_many :reviews, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :subtotal, presence: true, numericality: { greater_than: 0 }

  before_validation :calculate_subtotal
  after_create :decrease_inventory
  after_destroy :restore_inventory

  def calculate_subtotal
    self.subtotal = (price * quantity).round(2) if price.present? && quantity.present?
  end

  def restore_inventory
    return unless product_variant.inventory

    inventory = product_variant.inventory
    inventory.with_lock do
      inventory.quantity += quantity
      inventory.save!
    end
  rescue => e
    Rails.logger.error "Failed to restore inventory for order item #{id}: #{e.message}"
  end

  private

  def decrease_inventory
    return unless product_variant.inventory

    inventory = product_variant.inventory
    inventory.with_lock do
      if inventory.quantity >= quantity
        inventory.quantity -= quantity
        inventory.save!
      else
        errors.add(:base, "Insufficient stock for #{product_variant.name}")
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end
  end
end
