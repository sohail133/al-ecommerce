class PagesController < ApplicationController
  def home
    @store_setting = StoreSetting.instance
    @categories = Category.includes(:products, image_attachment: :blob).order(:name)
    @featured_products = Product.active.includes(:category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob).limit(8)
    @best_sellers = Product.active.includes(:product_variants, :category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob).limit(4)
    @hero_images = HeroImage.active.ordered.includes(images_attachments: :blob)
  end

  def about
    @store_setting = StoreSetting.instance
  end

  def contact
    @store_setting = StoreSetting.instance
    @contact_us = ContactUs.new
  end
end
