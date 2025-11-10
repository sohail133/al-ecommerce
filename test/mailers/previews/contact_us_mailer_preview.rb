# Preview all emails at http://localhost:3000/rails/mailers/contact_us_mailer
class ContactUsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/contact_us_mailer/send_reply
  def send_reply
    ContactUsMailer.send_reply
  end
end
