class ContactUsController < ApplicationController
  def create
    @contact_us = ContactUs.new(contact_us_params)

    if @contact_us.save
      redirect_to contact_path, notice: "Thank you for contacting us! We'll get back to you soon."
    else
      @store_setting = StoreSetting.instance
      render "pages/contact", status: :unprocessable_entity, layout: "application"
    end
  end

  private

  def contact_us_params
    params.require(:contact_us).permit(:name, :email, :subject, :message)
  end
end

