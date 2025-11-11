class CartController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :redirect_guest_to_login, only: [:show]

  def show
    @cart = current_user.cart || current_user.create_cart
  end

  def add
    variant_id = params[:variant_id].to_i
    quantity = params[:quantity].to_i
    quantity = 1 if quantity <= 0

    variant = ProductVariant.find_by(id: variant_id)
    
    unless variant
      redirect_back(fallback_location: products_path, alert: "Product variant not found")
      return
    end

    cart = current_user.cart || current_user.create_cart
    
    cart_item = cart.cart_items.find_or_initialize_by(product_variant_id: variant_id)
    
    if cart_item.new_record?
      cart_item.quantity = quantity
    else
      cart_item.quantity += quantity
    end
    
    cart_item.price_snapshot = variant.price
    cart_item.save

    redirect_back(fallback_location: products_path, notice: "Item added to cart successfully!")
  end

  def remove
    variant_id = params[:variant_id].to_i
    
    cart = current_user.cart
    if cart
      cart_item = cart.cart_items.find_by(product_variant_id: variant_id)
      cart_item&.destroy
    end
    
    redirect_back(fallback_location: cart_path, notice: "Item removed from cart")
  end

  def clear
    cart = current_user.cart
    cart&.cart_items&.destroy_all
    redirect_to products_path, notice: "Cart cleared"
  end

  def update_quantity
    cart_item = current_user.cart&.cart_items&.find_by(id: params[:id])
    
    if cart_item && params[:quantity].present?
      quantity = params[:quantity].to_i
      if quantity > 0
        cart_item.update(quantity: quantity)
        redirect_back(fallback_location: cart_path, notice: "Quantity updated")
      else
        cart_item.destroy
        redirect_back(fallback_location: cart_path, notice: "Item removed")
      end
    else
      redirect_back(fallback_location: cart_path, alert: "Invalid request")
    end
  end

  def update_variant
    cart_item = current_user.cart&.cart_items&.find_by(id: params[:id])
    variant = ProductVariant.find_by(id: params[:variant_id])
    
    if cart_item && variant
      cart_item.update(product_variant: variant, price_snapshot: variant.price)
      render json: { success: true }
    else
      render json: { success: false, error: "Invalid variant" }, status: :unprocessable_entity
    end
  end

  private

  def redirect_guest_to_login
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to view your cart"
    end
  end
end
