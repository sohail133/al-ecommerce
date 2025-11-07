module Admin::ProductsHelper
  def filters_active?
    params[:name].present? || params[:category_id].present? || params[:subcategory_id].present? || params[:status].present?
  end
end
