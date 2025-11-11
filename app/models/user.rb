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
  scope :by_name, ->(name) { where("full_name ILIKE ?", "%#{sanitize_sql_like(name)}%") }
  scope :by_email, ->(email) { where("email ILIKE ?", "%#{sanitize_sql_like(email)}%") }
  scope :by_role, ->(role) { where(role: role) }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }

  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_one :cart, dependent: :destroy

  def favorited_product_ids
    @favorited_product_ids ||= favorites.pluck(:product_id)
  end

  def favorited?(product_id)
    favorited_product_ids.include?(product_id)
  end

  after_create :create_cart

  def self.search(params)
    users = all
    users = users.by_name(params[:name]) if params[:name].present?
    users = users.by_email(params[:email]) if params[:email].present?
    users = users.by_role(params[:role]) if params[:role].present?
    users = users.by_status(params[:status]) if params[:status].present?
    users.recent
  end

  def active?
    status?
  end

  def inactive?
    !status?
  end

  private

  def create_cart
    Cart.create(user: self) unless cart
  end
end

