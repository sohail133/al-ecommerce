class Admin::ProductVariantsController < Admin::BaseController
  before_action :set_product_variant, only: [:show, :edit, :update, :destroy]

  def index
    @product_variants = ProductVariant.includes(:product).order(created_at: :desc)
    @product_variants = @product_variants.by_product(params[:product_id]) if params[:product_id].present?
  end

  def show
  end

  def new
    @product_variant = ProductVariant.new(product_id: params[:product_id])
    @products = Product.active.ordered
  end

  def create
    @product_variant = ProductVariant.new(product_variant_params)
    if @product_variant.save
      redirect_to admin_product_variant_path(@product_variant), notice: "Product variant created successfully"
    else
      @products = Product.active.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.active.ordered
  end

  def update
    if @product_variant.update(product_variant_params)
      redirect_to admin_product_variant_path(@product_variant), notice: "Product variant updated successfully"
    else
      @products = Product.active.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product_variant.destroy
    redirect_to admin_product_variants_path, notice: "Product variant deleted successfully"
  end

  private

  def set_product_variant
    @product_variant = ProductVariant.find(params[:id])
  end

  def product_variant_params
    params.require(:product_variant).permit(:product_id, :sku, :name, :price, :active)
  end
end
