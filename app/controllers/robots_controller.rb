# frozen_string_literal: true

class RobotsController < ApplicationController
  def show
    expires_in 6.hours, public: true
    render plain: robots_body, content_type: "text/plain"
  end

  private

  def robots_body
    <<~ROBOTS
      User-agent: *
      Allow: /
      Disallow: /admin
      Disallow: /admin/
      Disallow: /cart
      Disallow: /checkout
      Disallow: /dashboard
      Disallow: /orders
      Disallow: /favorites
      Disallow: /addresses
      Disallow: /users/sign_in
      Disallow: /users/sign_up
      Disallow: /users/password
      Disallow: /users/edit
      Disallow: /rails/
      Disallow: /up

      Sitemap: #{Site.absolute_url('/sitemap.xml')}
    ROBOTS
  end
end
