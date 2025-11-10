class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :confirmation]

  def index
    @orders = current_user.orders.includes(
      :address, 
      :payment_method, 
      order_items: {
        reviews: { images_attachments: :blob },
        product_variant: :product
      }
    ).recent.page(params[:page]).per(10)
  end

  def show
    redirect_to root_path, alert: "Order not found" unless @order.user == current_user
  end

  def confirmation
    redirect_to root_path, alert: "Order not found" unless @order.user == current_user
  end

  private

  def set_order
    @order = Order.includes(
      :user,
      :address,
      :payment_method,
      order_items: {
        reviews: { images_attachments: :blob },
        product_variant: {
          product: [:category, :subcategory]
        }
      }
    ).find_by(id: params[:id])
    
    redirect_to root_path, alert: "Order not found" unless @order
  end
end
