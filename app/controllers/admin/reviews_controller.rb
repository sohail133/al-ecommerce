class Admin::ReviewsController < Admin::BaseController
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_action :set_order_item, only: [:new, :create]

  def index
    @reviews = Review.includes(:order_item, :user, order_item: { product_variant: :product }, images_attachments: :blob).recent.page(params[:page]).per(20)
  end

  def show
  end

  def new
    @review = @order_item.reviews.build
    @users = User.customers.order(:full_name)
  end

  def create
    @review = @order_item.reviews.build(review_params)

    if @review.save
      redirect_to admin_review_path(@review), notice: "Review created successfully"
    else
      @users = User.customers.order(:full_name)
      render :new, status: :unprocessable_entity
    end
  end

  def new_standalone
    @review = Review.new
    @order_items = OrderItem.includes(order: :user, product_variant: :product).joins(:order).order("orders.created_at DESC").limit(100)
    @users = User.customers.order(:full_name)
  end

  def create_standalone
    @order_item = OrderItem.find(params[:review][:order_item_id])
    @review = @order_item.reviews.build(review_params)

    if @review.save
      redirect_to admin_review_path(@review), notice: "Review created successfully"
    else
      @order_items = OrderItem.includes(order: :user, product_variant: :product).joins(:order).order("orders.created_at DESC").limit(100)
      @users = User.customers.order(:full_name)
      render :new_standalone, status: :unprocessable_entity
    end
  end

  def edit
    @order_item = @review.order_item
    @users = User.customers.order(:full_name)
  end

  def update
    update_params = review_params
    images_param = update_params[:images]
    
    # Preserve existing images if no new ones are uploaded
    if images_param.blank? || (images_param.is_a?(Array) && images_param.reject(&:blank?).empty?)
      update_params = update_params.except(:images)
    end
    
    if @review.update(update_params)
      redirect_to admin_review_path(@review), notice: "Review updated successfully"
    else
      @order = @review.order
      @users = User.customers.order(:full_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to admin_reviews_path, notice: "Review deleted successfully"
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def set_order_item
    @order_item = OrderItem.find(params[:order_item_id])
  end

  def review_params
    params.require(:review).permit(:order_item_id, :user_id, :rating, :comment, images: [])
  end
end

