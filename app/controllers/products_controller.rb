class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = Product.search(filter_params).page(params[:page]).per(12)
    @categories = Category.includes(image_attachment: :blob).order(:name)
    @subcategories = Subcategory.includes(image_attachment: :blob).order(:name)
    @favorited_product_ids = user_signed_in? ? current_user.favorited_product_ids : []
    @seo_noindex = listing_filtered?
  end

  def new_arrivals
    @products = Product.search(filter_params.merge(sort: "newest")).page(params[:page]).per(12)
    @categories = Category.includes(image_attachment: :blob).order(:name)
    @subcategories = Subcategory.includes(image_attachment: :blob).order(:name)
    @favorited_product_ids = user_signed_in? ? current_user.favorited_product_ids : []
    @new_arrivals_page = true
    @seo_noindex = listing_filtered?(ignore_sort: true)
    render :index
  end

  def show
    @related_products = Product.active
                               .where(category_id: @product.category_id)
                               .where.not(id: @product.id)
                               .includes(:product_variants, :category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob)
                               .limit(4)
  end

  private

  def set_product
    @product = Product.includes(
      { category: :category_attributes },
      :subcategory,
      { product_variants: [:inventory, { attribute_values: :category_attribute }] },
      cover_image_attachment: :blob,
      images_attachments: :blob
    ).friendly.find(params[:id])
    @favorited_product_ids = user_signed_in? ? current_user.favorited_product_ids : []
  end

  def filter_params
    params.permit(:name, :category_id, :subcategory_id, :min_price, :max_price, :sort)
  end

  def listing_filtered?(ignore_sort: false)
    filtered = %i[name category_id subcategory_id min_price max_price].any? { |key| params[key].present? }
    return filtered if ignore_sort

    filtered || (params[:sort].present? && params[:sort] != "newest")
  end
end
