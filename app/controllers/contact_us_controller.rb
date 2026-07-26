class ContactUsController < ApplicationController
  def create
    @contact_us = ContactUs.new(contact_us_params)
    @store_setting = StoreSetting.instance

    unless RecaptchaVerifier.verify(params["g-recaptcha-response"], remote_ip: request.remote_ip)
      @contact_us.errors.add(:base, "Please complete the reCAPTCHA verification.")
      render "pages/contact", status: :unprocessable_entity, layout: "application"
      return
    end

    if @contact_us.save
      redirect_to contact_path, notice: "Thank you for contacting us! We'll get back to you soon."
    else
      render "pages/contact", status: :unprocessable_entity, layout: "application"
    end
  end

  private

  def contact_us_params
    params.require(:contact_us).permit(:name, :email, :subject, :message)
  end
end
