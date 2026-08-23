class Admin::ProductVariantsController < Admin::BaseController
  before_action :set_product_variant, only: [:show, :edit, :update, :destroy]
  before_action :load_products, only: [:index, :new, :edit, :create, :update]

  def index
    @product_variants = ProductVariant.includes(:product, :inventory).search(filter_params).page(params[:page])
  end

  def show
    @product_variant = ProductVariant.includes(attribute_values: :category_attribute).find(params[:id])
  end

  def new
    @product_variant = ProductVariant.new(product_id: params[:product_id])
    prepare_attribute_values
  end

  def create
    @product_variant = ProductVariant.new(product_variant_params)
    if @product_variant.save
      redirect_to admin_product_variant_path(@product_variant), notice: "Product variant created successfully"
    else
      prepare_attribute_values
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_attribute_values
  end

  def update
    if @product_variant.update(product_variant_params)
      redirect_to admin_product_variant_path(@product_variant), notice: "Product variant updated successfully"
    else
      prepare_attribute_values
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product_variant.destroy
    redirect_to admin_product_variants_path, notice: "Product variant deleted successfully"
  end

  def attribute_fields
    product = Product.includes(category: { category_attributes: :category_attribute_options }).find(params[:product_id])

    @product_variant = if params[:variant_id].present?
      ProductVariant.includes(attribute_values: :category_attribute).find(params[:variant_id])
    else
      ProductVariant.new
    end

    @product_variant.product = product
    @product_variant.build_missing_attribute_values

    render partial: "admin/product_variants/attribute_fields",
           locals: { product_variant: @product_variant },
           layout: false
  end

  private

  def set_product_variant
    @product_variant = ProductVariant.includes(
      :product,
      attribute_values: { category_attribute: :category_attribute_options }
    ).find(params[:id])
  end

  def load_products
    @products = Product.active.ordered
  end

  def prepare_attribute_values
    if @product_variant.product_id.present?
      @product_variant.product = Product.includes(
        category: { category_attributes: :category_attribute_options }
      ).find(@product_variant.product_id)
    end
    @product_variant.build_missing_attribute_values
  end

  def product_variant_params
    params.require(:product_variant).permit(
      :product_id,
      :sku,
      :name,
      :price,
      :active,
      attribute_values_attributes: [
        :id,
        :category_attribute_id,
        :value,
        :_destroy
      ]
    )
  end

  def filter_params
    params.permit(:product_id, :status)
  end
end
