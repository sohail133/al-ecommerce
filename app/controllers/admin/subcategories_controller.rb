class Admin::SubcategoriesController < Admin::BaseController
  before_action :set_subcategory, only: [:show, :edit, :update, :destroy]
  before_action :load_categories, only: [:index, :new, :edit, :create, :update]

  def index
    @subcategories = Subcategory.search(filter_params).page(params[:page])
  end

  def show; end

  def new
    @subcategory = Subcategory.new
  end

  def create
    @subcategory = Subcategory.new(subcategory_params)
    if @subcategory.save
      redirect_to admin_subcategory_path(@subcategory), notice: "Subcategory created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @subcategory.update(subcategory_params)
      redirect_to admin_subcategory_path(@subcategory), notice: "Subcategory updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subcategory.destroy
    redirect_to admin_subcategories_path, notice: "Subcategory deleted successfully"
  end

  private

  def set_subcategory
    @subcategory = Subcategory.friendly.find(params[:id])
  end

  def load_categories
    @categories = Category.ordered
  end

  def subcategory_params
    params.require(:subcategory).permit(:category_id, :name, :description, :image)
  end

  def filter_params
    params.permit(:name, :category_id)
  end
end
