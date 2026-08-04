class ProductVariant < ApplicationRecord
  belongs_to :product
  has_one :inventory, dependent: :destroy
  has_many :order_items, dependent: :nullify
  has_many :attribute_values,
           class_name: "ProductVariantAttributeValue",
           dependent: :destroy,
           inverse_of: :product_variant

  accepts_nested_attributes_for :attribute_values,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs["value"].blank? && attrs["id"].blank? }

  validates :sku, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :product_id, presence: true
  validate :required_category_attributes_present
  validate :size_present_for_sized_subcategory

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  scope :by_status, ->(status) { where(active: status) }

  before_validation :cleanup_blank_optional_attribute_values
  before_validation :sync_name_from_attributes
  after_create :create_inventory

  def self.search(params)
    variants = includes(:product, :inventory)
    variants = variants.by_product(params[:product_id]) if params[:product_id].present?
    variants = variants.by_status(params[:status]) if params[:status].present?
    variants.recent
  end

  def active?
    active
  end

  def available_quantity
    inventory&.available_quantity || 0
  end

  def low_stock?
    inventory&.low_stock? || false
  end

  def attribute_value_for(category_attribute)
    attribute_values.find { |value| value.category_attribute_id == category_attribute.id }
  end

  def attributes_summary
    attribute_values
      .includes(:category_attribute)
      .sort_by { |value| value.category_attribute.position }
      .map { |value| "#{value.category_attribute.name}: #{value.value}" }
      .join(" · ")
  end

  def build_missing_attribute_values
    return unless product&.category

    existing_ids = attribute_values.map(&:category_attribute_id)
    product.category.category_attributes.ordered.each do |attribute|
      next if existing_ids.include?(attribute.id)

      attribute_values.build(category_attribute: attribute)
    end
  end

  private

  def cleanup_blank_optional_attribute_values
    attribute_values.each do |attribute_value|
      next if attribute_value.value.present?
      next if attribute_value.category_attribute&.required?
      next unless attribute_value.persisted?

      attribute_value.mark_for_destruction
    end
  end

  def sync_name_from_attributes
    values = attribute_values.reject { |value| value.marked_for_destruction? || value.value.blank? }
    return if values.empty?

    ordered_values = values.sort_by do |value|
      value.category_attribute&.position || 999
    end

    self.name = ordered_values.map(&:value).join(" / ")
  end

  def required_category_attributes_present
    return unless product&.category

    product.category.category_attributes.where(required: true).each do |attribute|
      value = attribute_values.find { |item| item.category_attribute_id == attribute.id && !item.marked_for_destruction? }
      if value.blank? || value.value.blank?
        errors.add(:base, "#{attribute.name} is required for this category")
      end
    end
  end

  def size_present_for_sized_subcategory
    subcategory = product&.subcategory
    return unless subcategory&.size_required?

    size_attributes = subcategory.size_attributes
    return if size_attributes.empty?

    has_size = size_attributes.any? do |attribute|
      value = attribute_values.find { |item| item.category_attribute_id == attribute.id && !item.marked_for_destruction? }
      value.present? && value.value.present?
    end

    return if has_size

    errors.add(:base, "#{size_attributes.map(&:name).join(" or ")} is required for #{subcategory.name}")
  end

  def create_inventory
    Inventory.create(product_variant: self) unless inventory
  end
end
