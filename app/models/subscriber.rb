class Subscriber < ApplicationRecord
  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true, inclusion: { in: %w[active unsubscribed] }
  
  # Callbacks
  before_validation :normalize_email
  before_create :set_subscribed_at
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :unsubscribed, -> { where(status: 'unsubscribed') }
  scope :recent, -> { order(created_at: :desc) }
  scope :search, ->(query) { where("email LIKE ?", "%#{query}%") if query.present? }
  
  # Class methods
  def self.by_status(status)
    where(status: status) if status.present?
  end
  
  # Instance methods
  def active?
    status == 'active'
  end
  
  def unsubscribe!
    update(status: 'unsubscribed', unsubscribed_at: Time.current)
  end
  
  def resubscribe!
    update(status: 'active', subscribed_at: Time.current, unsubscribed_at: nil)
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def set_subscribed_at
    self.subscribed_at ||= Time.current
  end
end
