class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.includes(:category, :subcategory).order(created_at: :desc)
  end

  def show
    @product.product_variants.load
  end

  def new
    @product = Product.new
    @categories = Category.ordered
    @subcategories = Subcategory.ordered
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_product_path(@product), notice: "Product created successfully"
    else
      @categories = Category.ordered
      @subcategories = Subcategory.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.ordered
    @subcategories = Subcategory.ordered
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: "Product updated successfully"
    else
      @categories = Category.ordered
      @subcategories = Subcategory.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Product deleted successfully"
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:category_id, :subcategory_id, :title, :description, :price, :active)
  end
end
