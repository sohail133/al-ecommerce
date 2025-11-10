class ContactUsMailer < ApplicationMailer
  def send_reply(contact_us)
    @contact_us = contact_us
    @store_setting = StoreSetting.instance

    mail(
      to: @contact_us.email,
      subject: "Re: #{@contact_us.subject}",
      from: @store_setting.email
    )
  end
end
