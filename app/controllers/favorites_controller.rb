class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:create, :destroy]

  def index
    @favorites = current_user.favorites.includes(
      product: [
        :category, 
        :subcategory, 
        { cover_image_attachment: :blob },
        { images_attachments: :blob },
        { product_variants: :inventory }
      ]
    ).order(created_at: :desc)
    @favorited_product_ids = current_user.favorited_product_ids
  end

  def create
    @favorite = current_user.favorites.find_or_initialize_by(product: @product)
    
    respond_to do |format|
      if @favorite.save
        current_user.favorites.reset
        format.turbo_stream
        format.html { redirect_back(fallback_location: product_path(@product), notice: "Added to favorites") }
        format.json { render json: { status: 'success', favorite: @favorite } }
      else
        format.html { redirect_back(fallback_location: product_path(@product), alert: "Could not add to favorites") }
        format.json { render json: { status: 'error', errors: @favorite.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @favorite = current_user.favorites.find_by(product: @product)
    
    respond_to do |format|
      if @favorite
        if @favorite.destroy
          current_user.favorites.reset
          format.turbo_stream
          format.html { redirect_back(fallback_location: product_path(@product), notice: "Removed from favorites") }
          format.json { render json: { status: 'success' } }
        else
          format.html { redirect_back(fallback_location: product_path(@product), alert: "Could not remove from favorites: #{@favorite.errors.full_messages.join(', ')}") }
          format.json { render json: { status: 'error', errors: @favorite.errors }, status: :unprocessable_entity }
        end
      else
        current_user.favorites.reset
        format.turbo_stream
        format.html { redirect_back(fallback_location: product_path(@product), notice: "Already removed from favorites") }
        format.json { render json: { status: 'success' } }
      end
    end
  end

  private

  def set_product
    # The route uses :id which is the product slug (friendly_id)
    @product = Product.friendly.find(params[:id])
  end
end
