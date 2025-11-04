class Address < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :nullify

  validates :full_name, presence: true
  validates :phone_number, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :province, presence: true
  validates :postal_code, presence: true

  scope :default, -> { where(is_default: true) }

  before_save :set_default_address, if: :is_default?

  private

  def set_default_address
    user.addresses.where.not(id: id).update_all(is_default: false)
  end
end
