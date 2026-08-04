class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.search(filter_params).page(params[:page])
  end

  def show
    @category = Category.includes(category_attributes: :category_attribute_options).friendly.find(params[:id])
  end

  def new
    @category = Category.new
    @category.category_attributes.build(position: 0, input_type: "select")
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_category_path(@category), notice: "Category created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @category = Category.includes(category_attributes: :category_attribute_options).friendly.find(params[:id])
    if @category.category_attributes.empty?
      @category.category_attributes.build(position: 0, input_type: "select")
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_category_path(@category), notice: "Category updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: "Category deleted successfully"
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def category_params
    params.require(:category).permit(
      :name,
      :description,
      :image,
      category_attributes_attributes: [
        :id,
        :name,
        :slug,
        :input_type,
        :required,
        :position,
        :_destroy,
        category_attribute_options_attributes: [
          :id,
          :value,
          :position,
          :_destroy
        ]
      ]
    )
  end

  def filter_params
    params.permit(:name)
  end
end
