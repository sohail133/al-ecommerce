module Admin::SubcategoriesHelper
  def filters_active?
    params[:name].present? || params[:category_id].present?
  end
end
