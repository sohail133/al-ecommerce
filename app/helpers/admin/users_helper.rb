module Admin::UsersHelper
  def filters_active?
    params[:name].present? || params[:email].present? || params[:role].present? || params[:status].present?
  end
end
