class PaymentMethod < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  has_many :orders, dependent: :nullify

  def active?
    active
  end
end
