class Admin::StoreSettingsController < Admin::BaseController
  before_action :set_store_setting

  def show
  end

  def edit
  end

  def update
    if @store_setting.update(store_setting_params)
      redirect_to admin_store_setting_path, notice: "Store settings updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_store_setting
    @store_setting = StoreSetting.instance
  end

  def store_setting_params
    permitted = params.require(:store_setting).permit(
      :email, :location, :phone_number, :facebook_url, :instagram_url, :youtube_url, :shipping_fee,
      :banner_enabled, :banner_text, :banner_background_color, :banner_text_color
    )

    # Blank colors mean "follow the site theme", which the color pickers cannot express.
    if params[:use_theme_banner_colors] == "1"
      permitted[:banner_background_color] = nil
      permitted[:banner_text_color] = nil
    end

    permitted
  end
end

