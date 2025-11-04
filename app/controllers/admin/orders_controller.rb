class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:show, :edit, :update]

  def index
    @orders = Order.includes(:user, :address, :payment_method).recent
  end

  def show
    @order_items = @order.order_items.includes(:product_variant)
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Order updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
