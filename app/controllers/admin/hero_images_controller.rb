class Admin::HeroImagesController < Admin::BaseController
  before_action :set_hero_image, only: [:show, :edit, :update, :destroy, :toggle_active, :delete_image]

  def index
    @hero_images = HeroImage.ordered.includes(images_attachments: :blob)
  end

  def show
  end

  def new
    @hero_image = HeroImage.new
  end

  def create
    @hero_image = HeroImage.new(hero_image_params)
    if @hero_image.save
      redirect_to admin_hero_images_path, notice: "Hero image created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    update_params = hero_image_params
    images_param = update_params[:images]
    
    if images_param.blank? || (images_param.is_a?(Array) && images_param.reject(&:blank?).empty?)
      update_params = update_params.except(:images)
    end
    
    if @hero_image.update(update_params)
      redirect_to admin_hero_images_path, notice: "Hero image updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @hero_image.destroy
    redirect_to admin_hero_images_path, notice: "Hero image deleted successfully"
  end

  def toggle_active
    @hero_image.update(active: !@hero_image.active)
    redirect_to admin_hero_images_path, notice: "Hero image #{@hero_image.active? ? 'activated' : 'deactivated'} successfully"
  end

  def delete_image
    image = @hero_image.images.find_by(id: params[:image_id])
    if image
      image.purge
      redirect_to edit_admin_hero_image_path(@hero_image), notice: "Image deleted successfully"
    else
      redirect_to edit_admin_hero_image_path(@hero_image), alert: "Image not found"
    end
  end

  private

  def set_hero_image
    @hero_image = HeroImage.find(params[:id])
  end

  def hero_image_params
    params.require(:hero_image).permit(:title, :subtitle, :description, :active, :position, images: [])
  end
end

