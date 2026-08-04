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
  validates :shipping_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
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

  before_validation :snapshot_shipping_fee, on: :create
  before_validation :calculate_total, on: :create
  before_create :assign_order_number
  after_update :restore_inventory_on_cancel, if: :saved_change_to_status?

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

  # Human-friendly identifier shown to admins and customers (e.g. 20260726001).
  # Falls back to the raw id for any legacy record without a number.
  def display_number
    order_number.presence || id.to_s
  end

  def items_subtotal
    order_items.sum(&:subtotal)
  end

  private

  # Store-wide daily sequence: YYYYMMDD + zero-padded counter (001, 002, ... 010).
  def assign_order_number
    return if order_number.present?

    prefix = Time.current.strftime("%Y%m%d")
    last_number = self.class
                      .where("order_number LIKE ?", "#{prefix}%")
                      .order(order_number: :desc)
                      .limit(1)
                      .pick(:order_number)

    sequence = last_number ? last_number[8..].to_i + 1 : 1
    self.order_number = format("%s%03d", prefix, sequence)
  end

  def calculate_total
    return unless order_items.any?

    self.total_amount = items_subtotal + shipping_fee.to_d
  end

  # Lock in the admin-configured fee at order time so later setting changes
  # do not rewrite historical order totals.
  def snapshot_shipping_fee
    self.shipping_fee = StoreSetting.current_shipping_fee
  end

  def restore_inventory_on_cancel
    # Restore inventory when order is canceled
    if canceled? && status_was != 'canceled'
      order_items.each do |order_item|
        order_item.restore_inventory
      end
    end
  end
end
