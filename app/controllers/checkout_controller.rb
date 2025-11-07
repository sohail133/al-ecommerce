class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :load_checkout_data
  before_action :load_cart

  def show
    redirect_to root_path, alert: "Your cart is empty" if @cart.cart_items.empty?
    @order = Order.new
  end

  def create
    @cart = current_user.cart || current_user.create_cart
    
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
      return
    end

    @order = current_user.orders.build(order_params)
    
    @cart.cart_items.each do |cart_item|
      @order.order_items.build(
        product_variant: cart_item.product_variant,
        quantity: cart_item.quantity,
        price: cart_item.price_snapshot,
        subtotal: cart_item.subtotal
      )
    end

    if @order.save
      @cart.cart_items.destroy_all
      redirect_to order_confirmation_path(@order), notice: "Order placed successfully!"
    else
      load_checkout_data
      render :show, status: :unprocessable_entity
    end
  end

  private

  def load_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def load_checkout_data
    @addresses = current_user.addresses.order(is_default: :desc, created_at: :desc)
    @payment_methods = PaymentMethod.active.order(:name)
  end

  def order_params
    if params[:order].present?
      params.require(:order).permit(:address_id, :payment_method_id)
    else
      {}
    end
  end
end
