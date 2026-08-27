class StoreSetting < ApplicationRecord
  HEX_COLOR_FORMAT = /\A#(?:\h{3}|\h{6})\z/
  DEFAULT_BANNER_TEXT = "Free shipping on selected orders · Cash on Delivery available".freeze

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true
  validates :location, presence: true
  validates :shipping_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :banner_text, presence: true, if: :banner_enabled?

  validate :valid_url_format
  validate :valid_banner_colors
  validate :valid_whatsapp_number

  def self.instance
    first_or_create! do |setting|
      setting.email = "info@mahnira.com"
      setting.phone_number = "+1 234 567 8900"
      setting.location = "123 Main Street, City, State, ZIP Code"
      setting.shipping_fee = 0
      setting.banner_text = DEFAULT_BANNER_TEXT
    end
  end

  def self.current_shipping_fee
    instance.shipping_fee.to_d
  end

  def banner_visible?
    banner_enabled? && banner_text.present?
  end

  # Colors are optional: when blank the banner falls back to the theme's
  # green-primary/white so it keeps following light and dark themes.
  def banner_style
    styles = []
    styles << "background-color: #{banner_background_color}" if banner_background_color.present?
    styles << "color: #{banner_text_color}" if banner_text_color.present?
    styles.join("; ").presence
  end

  def banner_css_classes
    classes = []
    classes << "bg-green-primary" if banner_background_color.blank?
    classes << "text-white" if banner_text_color.blank?
    classes.join(" ")
  end

  def whatsapp_enabled?
    whatsapp_digits.present?
  end

  # Opens WhatsApp chat for this store number.
  # Accepts values like +92 300 1234567, 03001234567, or 923001234567.
  def whatsapp_chat_url(message: nil)
    return nil unless whatsapp_enabled?

    url = "https://wa.me/#{whatsapp_digits}"
    return url if message.blank?

    "#{url}?text=#{ERB::Util.url_encode(message)}"
  end

  def whatsapp_digits
    digits = whatsapp_number.to_s.gsub(/\D/, "")
    return "" if digits.blank?

    # Convert local Pakistani numbers (03XXXXXXXXX) to international format.
    digits = "92#{digits[1..]}" if digits.match?(/\A03\d{9}\z/)
    digits
  end

  private

  def valid_url_format
    [:facebook_url, :instagram_url, :youtube_url].each do |attr|
      url = send(attr)
      if url.present? && !url.match?(/\Ahttps?:\/\/.+/)
        errors.add(attr, "must be a valid URL starting with http:// or https://")
      end
    end
  end

  def valid_banner_colors
    [:banner_background_color, :banner_text_color].each do |attr|
      color = send(attr)
      next if color.blank?

      errors.add(attr, "must be a hex color like #4a7c59") unless color.match?(HEX_COLOR_FORMAT)
    end
  end

  def valid_whatsapp_number
    return if whatsapp_number.blank?

    digits = whatsapp_digits
    unless digits.match?(/\A\d{10,15}\z/)
      errors.add(:whatsapp_number, "must be a valid phone number with country code (e.g. +92 300 1234567)")
    end
  end
end
