class CategoryAttribute < ApplicationRecord
  INPUT_TYPES = %w[select text].freeze

  belongs_to :category
  has_many :category_attribute_options, -> { order(:position, :value) }, dependent: :destroy, inverse_of: :category_attribute
  has_many :product_variant_attribute_values, dependent: :destroy

  accepts_nested_attributes_for :category_attribute_options,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs["value"].blank? }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :category_id }
  validates :input_type, inclusion: { in: INPUT_TYPES }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :generate_slug

  scope :ordered, -> { order(:position, :name) }

  def select?
    input_type == "select"
  end

  def text?
    input_type == "text"
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if name.present? && slug.blank?
  end
end
