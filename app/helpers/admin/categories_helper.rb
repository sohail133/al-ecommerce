module Admin::CategoriesHelper
  def filters_active?
    params[:name].present?
  end
end
