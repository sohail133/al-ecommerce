class Admin::InventoriesController < Admin::BaseController
  before_action :set_inventory, only: [:update]

  def edit
    if params[:id].present?
      @inventory = Inventory.find(params[:id])
    elsif params[:product_variant_id].present?
      product_variant = ProductVariant.find(params[:product_variant_id])
      @inventory = product_variant.inventory || Inventory.new(product_variant: product_variant)
    else
      render_404
    end
  end

  def create
    @inventory = Inventory.new(inventory_params)
    if @inventory.save
      redirect_to admin_product_variant_path(@inventory.product_variant), notice: "Inventory created successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update
    if @inventory.update(inventory_params)
      redirect_to admin_product_variant_path(@inventory.product_variant), notice: "Inventory updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:id])
  end

  def inventory_params
    params.require(:inventory).permit(:product_variant_id, :quantity, :reserved_quantity, :threshold_level)
  end
end
