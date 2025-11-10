class ApplicationMailer < ActionMailer::Base
  default from: -> { StoreSetting.instance.email }
  layout "mailer"
end
