class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, customer: 1 }

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true

  scope :active, -> { where(status: true) }
  scope :inactive, -> { where(status: false) }
  scope :admins, -> { where(role: :admin) }
  scope :customers, -> { where(role: :customer) }

  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy

  def active?
    status?
  end

  def inactive?
    !status?
  end
end
