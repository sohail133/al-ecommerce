class ContactUs < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :message, presence: true

  scope :replied, -> { where.not(replied_at: nil) }
  scope :unreplied, -> { where(replied_at: nil) }
  scope :ordered, -> { order(created_at: :desc) }

  def replied?
    replied_at.present?
  end
end
