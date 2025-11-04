class Admin::AddressesController < Admin::BaseController
  def index
    @addresses = Address.includes(:user).order(created_at: :desc)
  end

  def show
    @address = Address.find(params[:id])
  end
end
