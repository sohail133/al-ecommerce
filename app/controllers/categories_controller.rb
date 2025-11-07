class CategoriesController < ApplicationController
  def show
    @category = Category.includes(:products, :subcategories, image_attachment: :blob).friendly.find(params[:id])
    @products = @category.products.active
                         .includes(:category, :subcategory, cover_image_attachment: :blob, images_attachments: :blob)
                         .page(params[:page]).per(12)
    @subcategories = @category.subcategories.ordered
  end
end

