class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  has_one_attached :cover_image
  has_many_attached :images
  
  belongs_to :category
  belongs_to :subcategory, optional: true
  has_many :product_variants, dependent: :destroy
  has_many :favorites, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category_id, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :ordered, -> { order(title: :asc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_name, ->(name) { where("products.title ILIKE ?", "%#{sanitize_sql_like(name)}%") }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_subcategory, ->(subcategory_id) { where(subcategory_id: subcategory_id) }
  scope :by_status, ->(status) { where(active: status) }
  scope :by_min_price, ->(min_price) { where("price >= ?", min_price) }
  scope :by_max_price, ->(max_price) { where("price <= ?", max_price) }

  def self.search(params)
    products = includes(:category, :subcategory, :product_variants, cover_image_attachment: :blob, images_attachments: :blob)
    products = products.active unless params[:status].present?
    products = products.by_name(params[:name]) if params[:name].present?
    products = products.by_category(params[:category_id]) if params[:category_id].present?
    products = products.by_subcategory(params[:subcategory_id]) if params[:subcategory_id].present?
    products = products.by_status(params[:status]) if params[:status].present?
    products = products.by_min_price(params[:min_price]) if params[:min_price].present?
    products = products.by_max_price(params[:max_price]) if params[:max_price].present?
    
    case params[:sort]
    when 'price_asc'
      products = products.order(price: :asc)
    when 'price_desc'
      products = products.order(price: :desc)
    when 'name_asc'
      products = products.order(title: :asc)
    else
      products = products.recent
    end
    
    products
  end

  def active?
    active
  end

  def variants_count
    product_variants.count
  end

  def average_rating
    reviews = Review.joins(order_item: :product_variant)
                   .where(product_variants: { product_id: id })
    return 0.0 if reviews.empty?
    reviews.average(:rating).round(1)
  end

  def review_count
    Review.joins(order_item: :product_variant)
          .where(product_variants: { product_id: id })
          .count
  end
end
