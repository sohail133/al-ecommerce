class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :delete_image]
  before_action :load_filter_data, only: [:index, :new, :edit, :create, :update]

  def index
    @products = Product.search(filter_params).page(params[:page])
  end

  def show
    @product.product_variants.load
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_product_path(@product), notice: "Product created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    attrs = product_params
    attrs = attrs.except(:images) unless uploaded_files?(attrs[:images])
    attrs = attrs.except(:cover_image) unless uploaded_file?(attrs[:cover_image])

    if @product.update(attrs)
      redirect_to admin_product_path(@product), notice: "Product updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Product deleted successfully"
  end

  def delete_image
    image = @product.images.find(params[:image_id])
    image.purge
    redirect_to edit_admin_product_path(@product), notice: "Image deleted successfully"
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id])
  end

  def load_filter_data
    @categories = Category.ordered
    @subcategories = Subcategory.ordered
  end

  def product_params
    params.require(:product).permit(
      :category_id, :subcategory_id, :title, :description, :price, :active,
      :seo_title, :seo_description, :public_url, :cover_image, images: []
    )
  end

  def uploaded_files?(files)
    Array(files).reject(&:blank?).any?
  end

  def uploaded_file?(file)
    file.present?
  end

  def filter_params
    params.permit(:name, :category_id, :subcategory_id, :status)
  end
end
