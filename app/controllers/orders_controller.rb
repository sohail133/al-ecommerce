class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:confirmation]

  def confirmation
    redirect_to root_path, alert: "Order not found" unless @order.user == current_user
  end

  private

  def set_order
    @order = Order.includes(:user, :address, :payment_method, order_items: :product_variant).find(params[:id])
  end
end

