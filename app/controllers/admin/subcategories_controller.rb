class Admin::SubcategoriesController < Admin::BaseController
  before_action :set_subcategory, only: [:show, :edit, :update, :destroy]

  def index
    @subcategories = Subcategory.includes(:category).order(created_at: :desc)
  end

  def show
  end

  def new
    @subcategory = Subcategory.new
    @categories = Category.ordered
  end

  def create
    @subcategory = Subcategory.new(subcategory_params)
    if @subcategory.save
      redirect_to admin_subcategory_path(@subcategory), notice: "Subcategory created successfully"
    else
      @categories = Category.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.ordered
  end

  def update
    if @subcategory.update(subcategory_params)
      redirect_to admin_subcategory_path(@subcategory), notice: "Subcategory updated successfully"
    else
      @categories = Category.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subcategory.destroy
    redirect_to admin_subcategories_path, notice: "Subcategory deleted successfully"
  end

  private

  def set_subcategory
    @subcategory = Subcategory.find(params[:id])
  end

  def subcategory_params
    params.require(:subcategory).permit(:category_id, :name, :description)
  end
end
