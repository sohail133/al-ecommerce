class PagesController < ApplicationController
  def home
    @store_setting = StoreSetting.instance
    @categories = Category.includes(:products, image_attachment: :blob).order(:name)
    @shop_collections = Subcategory.includes(:category, image_attachment: :blob)
                                   .joins(:category)
                                   .order("categories.name ASC, subcategories.name ASC")
                                   .limit(8)
    @featured_products = Product.active
                                .includes(:product_variants, :category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob)
                                .limit(8)
    @new_arrivals = Product.active.recent
                           .includes(:product_variants, :category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob)
                           .limit(8)
    @best_sellers = Product.active
                           .includes(:product_variants, :category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob)
                           .limit(8)
    @hero_images = HeroImage.active.ordered.includes(images_attachments: :blob)
    @recent_reviews = Review.includes(:user, order_item: { product_variant: :product })
                            .recent
                            .limit(6)
    @favorited_product_ids = user_signed_in? ? current_user.favorited_product_ids : []
  end

  def collections
    @store_setting = StoreSetting.instance
    @categories = Category.includes(:subcategories, image_attachment: :blob).order(:name)
  end

  def about
    @store_setting = StoreSetting.instance
  end

  def contact
    @store_setting = StoreSetting.instance
    @contact_us = ContactUs.new
  end

  def returns
    @store_setting = StoreSetting.instance
  end

  def shipping
    @store_setting = StoreSetting.instance
  end

  def faqs
    @store_setting = StoreSetting.instance
  end

  def privacy
    @store_setting = StoreSetting.instance
  end

  def terms
    @store_setting = StoreSetting.instance
  end

  def cookies
    @store_setting = StoreSetting.instance
  end
end
