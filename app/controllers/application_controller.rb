class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_default_url_options
  before_action :mark_private_pages_noindex

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name])
  end

  def render_404
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def set_default_url_options
    uri = URI.parse(Site.url)
    opts = { host: uri.host, protocol: uri.scheme }
    opts[:port] = uri.port if uri.port && ![80, 443].include?(uri.port)
    Rails.application.routes.default_url_options = opts
    ActiveStorage::Current.url_options = opts
  rescue URI::InvalidURIError
    # Keep existing defaults if SITE_URL is malformed.
  end

  def mark_private_pages_noindex
    @seo_noindex = true if private_seo_path?
  end

  def private_seo_path?
    request.path.start_with?(
      "/admin", "/cart", "/checkout", "/dashboard", "/orders",
      "/favorites", "/addresses", "/users"
    )
  end
end
