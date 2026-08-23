class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  has_one_attached :image
  
  has_many :subcategories, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :category_attributes, -> { ordered }, dependent: :destroy, inverse_of: :category

  accepts_nested_attributes_for :category_attributes,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs["name"].blank? }

  validates :name, presence: true, uniqueness: true
  validates :seo_title, length: { maximum: 70 }, allow_blank: true
  validates :seo_description, length: { maximum: 180 }, allow_blank: true

  scope :ordered, -> { order(name: :asc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{sanitize_sql_like(name)}%") }

  def self.search(params)
    categories = includes(:subcategories, :products, image_attachment: :blob)
    categories = categories.by_name(params[:name]) if params[:name].present?
    categories.recent
  end

  def products_count
    products.count
  end

  def subcategories_count
    subcategories.count
  end

  def seo_page_title
    seo_title.presence || "#{name} | Shop #{name} Online | Mahnira"
  end

  def seo_page_description
    seo_description.presence ||
      description.presence ||
      "Shop #{name} online at Mahnira. Browse quality products with convenient delivery across Pakistan."
  end
end
