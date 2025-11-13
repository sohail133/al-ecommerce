# Helper to easily access Rails credentials
# Usage: Rails.application.credentials_helper.database[:password]

module CredentialsHelper
  def self.get(key)
    Rails.application.credentials.public_send(key)
  rescue
    nil
  end
  
  def self.dig(*keys)
    Rails.application.credentials.dig(*keys)
  rescue
    nil
  end
end

# Make it easily accessible
Rails.application.config.after_initialize do
  Rails.application.define_singleton_method(:credentials_helper) do
    CredentialsHelper
  end
end

