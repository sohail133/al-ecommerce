# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/status_updated
  def status_updated
    order = Order.includes(:user, order_items: { product_variant: :product }).first
    OrderMailer.status_updated(order)
  end

  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/order_placed
  def order_placed
    order = Order.includes(:user, :address, :payment_method, order_items: { product_variant: :product }).first
    OrderMailer.order_placed(order)
  end
end
