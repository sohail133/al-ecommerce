class Admin::ProductVariantsController < Admin::BaseController
  before_action :set_product_variant, only: [:show, :edit, :update, :destroy]
  before_action :load_products, only: [:index, :new, :edit, :create, :update]

  def index
    @product_variants = ProductVariant.includes(:product, :inventory).search(filter_params).page(params[:page])
  end

  def show; end

  def new
    @product_variant = ProductVariant.new(product_id: params[:product_id])
  end

  def create
    @product_variant = ProductVariant.new(product_variant_params)
    if @product_variant.save
      redirect_to admin_product_variant_path(@product_variant), notice: "Product variant created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product_variant.update(product_variant_params)
      redirect_to admin_product_variant_path(@product_variant), notice: "Product variant updated successfully"
    else
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

  def load_products
    @products = Product.active.ordered
  end

  def product_variant_params
    params.require(:product_variant).permit(:product_id, :sku, :name, :price, :active)
  end

  def filter_params
    params.permit(:product_id, :status)
  end
end
