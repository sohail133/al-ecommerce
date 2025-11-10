class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @orders = current_user.orders.includes(
      :address, 
      :payment_method, 
      order_items: {
        reviews: { images_attachments: :blob },
        product_variant: :product
      }
    ).recent.page(params[:page]).per(10)
  end
end

