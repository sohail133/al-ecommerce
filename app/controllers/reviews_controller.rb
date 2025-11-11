class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order_item, only: [:create]

  def create
    @review = @order_item.reviews.build(review_params.merge(user: current_user))

    if @review.save
      redirect_to order_path(@order_item.order), notice: "Review submitted successfully!"
    else
      @order = @order_item.order
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
      ).find(@order.id)
      render "orders/show", status: :unprocessable_entity
    end
  end

  private

  def set_order_item
    @order_item = OrderItem.find(params[:order_item_id])
    @order = @order_item.order
    redirect_to root_path, alert: "Order not found" unless @order.user == current_user
  end

  def review_params
    params.require(:review).permit(:rating, :comment, images: [])
  end
end

