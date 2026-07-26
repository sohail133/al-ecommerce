class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :confirmation, :reorder]

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

  def reorder
    unless @order.user == current_user
      redirect_to dashboard_path, alert: "Order not found"
      return
    end

    cart = current_user.cart || current_user.create_cart
    added_count = 0
    skipped_items = []

    @order.order_items.includes(product_variant: :inventory).each do |order_item|
      variant = order_item.product_variant

      unless variant&.active?
        skipped_items << (variant&.name || "Unavailable item")
        next
      end

      available_quantity = variant.available_quantity
      if available_quantity <= 0
        skipped_items << variant.name
        next
      end

      quantity_to_add = [order_item.quantity, available_quantity].min
      cart_item = cart.cart_items.find_or_initialize_by(product_variant_id: variant.id)

      if cart_item.new_record?
        cart_item.quantity = quantity_to_add
      else
        cart_item.quantity = [cart_item.quantity + quantity_to_add, available_quantity].min
      end

      cart_item.price_snapshot = variant.price
      cart_item.save!
      added_count += 1
    end

    if added_count.zero?
      message = "Could not reorder. Items may be out of stock or unavailable."
      message += " Skipped: #{skipped_items.uniq.join(', ')}" if skipped_items.any?
      redirect_to dashboard_path, alert: message
    else
      notice = "Order ##{@order.id} items added to your cart."
      notice += " Some items were skipped: #{skipped_items.uniq.join(', ')}" if skipped_items.any?
      redirect_to cart_path, notice: notice
    end
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
