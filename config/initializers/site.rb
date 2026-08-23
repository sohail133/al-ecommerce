# frozen_string_literal: true

# Canonical site configuration for SEO, mailers, and absolute URLs.
# Set SITE_URL in production, e.g. https://mahnira.com (no trailing slash).
module Site
  BRAND = "Mahnira"
  DEFAULT_OG_IMAGE = "/images/logo.png"
  CURRENCY = "PKR"
  LOCALE = "en_PK"

  module_function

  def url
    configured = ENV["SITE_URL"].presence || ENV["APP_HOST"].presence
    return configured.to_s.chomp("/") if configured.present?

    case Rails.env
    when "development"
      port = ENV.fetch("PORT", "3000")
      "http://localhost:#{port}"
    when "staging"
      "https://#{ENV.fetch('STAGING_DOMAIN', 'staging.alecommerce.com')}"
    else
      host = Rails.application.config.action_mailer.default_url_options&.dig(:host).presence || "example.com"
      protocol = Rails.application.config.action_mailer.default_url_options&.dig(:protocol).presence || "https"
      port = Rails.application.config.action_mailer.default_url_options&.dig(:port)
      base = "#{protocol}://#{host}"
      port.present? && ![80, 443].include?(port.to_i) ? "#{base}:#{port}" : base
    end
  end

  def host
    URI.parse(url).host
  rescue URI::InvalidURIError
    "localhost"
  end

  def absolute_url(path = "/")
    return path if path.to_s.start_with?("http://", "https://")

    "#{url}#{path.to_s.start_with?("/") ? path : "/#{path}"}"
  end
end
