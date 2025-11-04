class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(name: :asc) }

  has_many :subcategories, dependent: :destroy
  has_many :products, dependent: :destroy

  def products_count
    products.count
  end

  def subcategories_count
    subcategories.count
  end
end
