class ProductVariant < ApplicationRecord
  belongs_to :product
  has_one :inventory, dependent: :destroy
  has_many :order_items, dependent: :nullify

  validates :sku, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :product_id, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }

  after_create :create_inventory

  def active?
    active
  end

  def available_quantity
    inventory&.available_quantity || 0
  end

  def low_stock?
    inventory&.low_stock? || false
  end

  private

  def create_inventory
    Inventory.create(product_variant: self) unless inventory
  end
end
