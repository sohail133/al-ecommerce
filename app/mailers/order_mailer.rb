class OrderMailer < ApplicationMailer
  helper ApplicationHelper

  def status_updated(order)
    @previous_status = order.status_previously_was
    @current_status = order.status
    load_order_details(order)

    mail(
      to: @user.email,
      subject: "Order ##{@order.id} status updated to #{@current_status.humanize}",
      from: @store_setting.email
    )
  end

  def order_placed(order)
    load_order_details(order)

    mail(
      to: @user.email,
      subject: "Order ##{@order.id} confirmed - Thank you for your purchase",
      from: @store_setting.email
    )
  end

  private

  def load_order_details(order)
    @order = Order.includes(
      :address,
      :payment_method,
      order_items: {
        product_variant: {
          product: [cover_image_attachment: :blob, images_attachments: :blob]
        }
      }
    ).find(order.id)
    @user = @order.user
    @store_setting = StoreSetting.instance
    @order_items = @order.order_items
  end
end
