class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_orders = Order.count
    @total_products = Product.count
    @total_revenue = Order.delivered.sum(:total_amount) || 0
    @recent_orders = Order.includes(:user).recent.limit(5)
    @pending_orders = Order.pending.count
    @active_products = Product.active.count
    @low_stock_items = Inventory.low_stock.count
  end
end
