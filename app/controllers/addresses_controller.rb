class AddressesController < ApplicationController
  before_action :authenticate_user!

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)
    @address.is_default = true if current_user.addresses.empty?

    if @address.save
      redirect_to checkout_path, notice: "Address added successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def address_params
    params.require(:address).permit(:full_name, :phone_number, :address_line_1, :address_line_2, :city, :province, :postal_code, :is_default)
  end
end

