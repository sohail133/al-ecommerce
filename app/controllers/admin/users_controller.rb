class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :activate, :deactivate]

  def index
    @users = User.search(filter_params).page(params[:page])
  end

  def show; end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def activate
    @user.update(status: true)
    redirect_to admin_user_path(@user), notice: "User activated successfully"
  end

  def deactivate
    @user.update(status: false)
    redirect_to admin_user_path(@user), notice: "User deactivated successfully"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :email)
  end

  def filter_params
    params.permit(:name, :email, :role, :status)
  end
end
