# frozen_string_literal: true

class SitemapsController < ApplicationController
  def show
    @products = Product.active.select(:id, :slug, :updated_at, :title)
    @categories = Category.select(:id, :slug, :updated_at, :name)

    expires_in 1.hour, public: true
    render formats: [:xml], layout: false
  end
end
