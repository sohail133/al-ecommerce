class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = Product.search(filter_params).page(params[:page]).per(12)
    @categories = Category.includes(image_attachment: :blob).order(:name)
    @subcategories = Subcategory.includes(image_attachment: :blob).order(:name)
  end

  def show
    @related_products = Product.active
                               .where(category_id: @product.category_id)
                               .where.not(id: @product.id)
                               .includes(:category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob)
                               .limit(4)
  end

  private

  def set_product
    @product = Product.includes(:category, :subcategory, :product_variants, 
                                cover_image_attachment: :blob, 
                                images_attachments: :blob).friendly.find(params[:id])
  end

  def filter_params
    params.permit(:name, :category_id, :subcategory_id, :min_price, :max_price, :sort)
  end
end
