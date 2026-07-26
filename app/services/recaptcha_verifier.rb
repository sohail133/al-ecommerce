require "net/http"
require "json"

class RecaptchaVerifier
  VERIFY_URL = URI("https://www.google.com/recaptcha/api/siteverify")

  # Google's publicly documented test keys always pass verification.
  TEST_SITE_KEY = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
  TEST_SECRET_KEY = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"

  def self.site_key
    ENV["RECAPTCHA_SITE_KEY"].presence || credential_key(:site_key) || TEST_SITE_KEY
  end

  def self.secret_key
    ENV["RECAPTCHA_SECRET_KEY"].presence || credential_key(:secret_key) || TEST_SECRET_KEY
  end

  def self.configured?
    site_key.present? && secret_key.present?
  end

  def self.verify(response_token, remote_ip: nil)
    return false if response_token.blank?

    response = Net::HTTP.post_form(
      VERIFY_URL,
      {
        "secret" => secret_key,
        "response" => response_token,
        "remoteip" => remote_ip
      }.compact
    )

    JSON.parse(response.body)["success"] == true
  rescue StandardError => e
    Rails.logger.error("reCAPTCHA verification failed: #{e.message}")
    false
  end

  def self.credential_key(name)
    Rails.application.credentials.dig(:recaptcha, name)
  rescue StandardError
    nil
  end
  private_class_method :credential_key
end
