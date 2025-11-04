class Product < ApplicationRecord
  belongs_to :category
  belongs_to :subcategory, optional: true
  has_many :product_variants, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category_id, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :ordered, -> { order(title: :asc) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_subcategory, ->(subcategory_id) { where(subcategory_id: subcategory_id) }

  def active?
    active
  end

  def variants_count
    product_variants.count
  end
end
