class ApplicationMailer < ActionMailer::Base
  default from: -> { 
    StoreSetting.instance.email rescue 'noreply@shopmovearc.com'
  }
  layout "mailer"
end
