module ApplicationHelper
  def user_avatar(user, size: 10, class_names: "")
    return "" unless user
    initial = user.full_name&.first&.upcase || user.email&.first&.upcase || "U"
    size_class = case size
                 when 8 then "h-8 w-8"
                 when 10 then "h-10 w-10"
                 when 12 then "h-12 w-12"
                 else "h-10 w-10"
                 end
    content_tag(:div, initial, class: "user-avatar #{size_class} text-sm #{class_names}")
  end

  def status_badge(status, type: :default)
    render "shared/status_badge", status: status, type: type
  end

  def format_currency(amount)
    number_to_currency(amount, unit: "Rs ", separator: ".", delimiter: ",", precision: 2)
  end

  def format_shipping_fee(amount)
    amount = amount.to_d
    amount.zero? ? "Free" : format_currency(amount)
  end

  def recaptcha_tags
    return "".html_safe unless RecaptchaVerifier.configured?

    content_tag(:div, class: "recaptcha-wrapper") do
      safe_join([
        tag.div(class: "g-recaptcha", data: { sitekey: RecaptchaVerifier.site_key }),
        javascript_include_tag("https://www.google.com/recaptcha/api.js", async: true, defer: true)
      ])
    end
  end
end
