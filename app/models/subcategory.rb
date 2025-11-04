class Subcategory < ApplicationRecord
  belongs_to :category
  has_many :products, dependent: :destroy

  validates :name, presence: true
  validates :category_id, presence: true

  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :ordered, -> { order(name: :asc) }

  def products_count
    products.count
  end
end
