module Admin::ProductVariantsHelper
  def filters_active?
    params[:product_id].present? || params[:status].present?
  end
end
