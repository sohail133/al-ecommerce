class Admin::ContactUsController < Admin::BaseController
  before_action :set_contact_us, only: [:show, :edit, :update, :destroy, :reply]

  def index
    @contact_us = ContactUs.ordered.page(params[:page]).per(20)
  end

  def show
  end

  def edit
  end

  def update
    if @contact_us.update(contact_us_params)
      redirect_to admin_contact_path(@contact_us), notice: "Contact query updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def reply
    if params[:contact_us].present? && params[:contact_us][:admin_response].present?
      if @contact_us.update(contact_us_params.merge(replied_at: Time.current))
        ContactUsMailer.send_reply(@contact_us).deliver_now
        redirect_to admin_contact_path(@contact_us), notice: "Reply sent successfully to #{@contact_us.email}."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to edit_admin_contact_path(@contact_us), alert: "Please enter a response before sending."
    end
  end

  def destroy
    @contact_us.destroy
    redirect_to admin_contacts_path, notice: "Contact query deleted successfully."
  end

  private

  def set_contact_us
    @contact_us = ContactUs.find(params[:id])
  end

  def contact_us_params
    params.require(:contact_us).permit(:admin_response)
  end
end

