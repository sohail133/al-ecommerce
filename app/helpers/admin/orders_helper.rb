module Admin::OrdersHelper
  def filters_active?
    params[:email].present? || params[:status].present? || params[:start_date].present? || 
    params[:end_date].present? || params[:min_price].present? || params[:max_price].present?
  end
end
