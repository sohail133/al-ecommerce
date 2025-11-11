class Subcategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  has_one_attached :image
  
  belongs_to :category
  has_many :products, dependent: :destroy

  validates :name, presence: true
  validates :category_id, presence: true

  scope :ordered, -> { order(name: :asc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_name, ->(name) { where("subcategories.name ILIKE ?", "%#{sanitize_sql_like(name)}%") }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  def self.search(params)
    subcategories = includes(:category, :products, image_attachment: :blob)
    subcategories = subcategories.by_name(params[:name]) if params[:name].present?
    subcategories = subcategories.by_category(params[:category_id]) if params[:category_id].present?
    subcategories.recent
  end

  def products_count
    products.count
  end
end
