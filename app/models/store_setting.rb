class StoreSetting < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true
  validates :location, presence: true
  
  validate :valid_url_format

  private

  def valid_url_format
    [:facebook_url, :instagram_url, :youtube_url].each do |attr|
      url = send(attr)
      if url.present? && !url.match?(/\Ahttps?:\/\/.+/)
        errors.add(attr, "must be a valid URL starting with http:// or https://")
      end
    end
  end

  def self.instance
    first_or_create! do |setting|
      setting.email = "info@alecommerce.com"
      setting.phone_number = "+1 234 567 8900"
      setting.location = "123 Main Street, City, State, ZIP Code"
    end
  end
end
