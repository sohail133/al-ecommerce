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
    params.require(:store_setting).permit(:email, :location, :phone_number, :facebook_url, :instagram_url, :youtube_url)
  end
end

