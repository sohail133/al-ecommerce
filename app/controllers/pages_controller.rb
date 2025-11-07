class PagesController < ApplicationController
  def home
    @categories = Category.includes(:products, image_attachment: :blob).order(:name)
    @featured_products = Product.active.includes(:category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob).limit(8)
    @best_sellers = Product.active.includes(:product_variants, :category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob).limit(4)
    @hero_slides = [
      {
        title: "Summer Collection 2024",
        subtitle: "Discover the latest trends",
        description: "Shop our newest arrivals and get up to 50% off on selected items",
        image_url: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&h=600&fit=crop"
      },
      {
        title: "Quality Products",
        subtitle: "Best prices guaranteed",
        description: "Experience premium quality at unbeatable prices",
        image_url: "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1200&h=600&fit=crop"
      },
      {
        title: "Fast Delivery",
        subtitle: "Free shipping over $50",
        description: "Get your products delivered to your doorstep in no time",
        image_url: "https://images.unsplash.com/photo-1607082349566-187342175e2f?w=1200&h=600&fit=crop"
      }
    ]
  end
end
