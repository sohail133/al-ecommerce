class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address
  belongs_to :payment_method
  has_many :order_items, dependent: :destroy
  has_many :reviews, through: :order_items

  enum :status, {
    pending: 0,
    accepted: 1,
    processing: 2,
    shipped: 3,
    delivered: 4,
    canceled: 5
  }

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :user_id, presence: true
  validates :address_id, presence: true
  validates :payment_method_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_customer_email, ->(email) { joins(:user).where("users.email ILIKE ?", "%#{sanitize_sql_like(email)}%") }
  scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }
  scope :by_min_price, ->(min_price) { where("total_amount >= ?", min_price) }
  scope :by_max_price, ->(max_price) { where("total_amount <= ?", max_price) }

  before_validation :calculate_total, on: :create

  def self.search(params)
    orders = includes(:user, :address, :payment_method, :order_items)
    orders = orders.by_customer_email(params[:email]) if params[:email].present?
    orders = orders.by_status(params[:status]) if params[:status].present?
    
    if params[:start_date].present? && params[:end_date].present?
      begin
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        orders = orders.by_date_range(start_date, end_date)
      rescue ArgumentError
        # Invalid date format, skip filter
      end
    end
    
    orders = orders.by_min_price(params[:min_price]) if params[:min_price].present?
    orders = orders.by_max_price(params[:max_price]) if params[:max_price].present?
    orders.recent
  end

  def can_cancel?
    pending? || accepted?
  end

  def can_update_status?
    !delivered? && !canceled?
  end

  def items_count
    order_items.sum(:quantity)
  end

  private

  def calculate_total
    self.total_amount = order_items.sum(&:subtotal) if order_items.any?
  end
end
