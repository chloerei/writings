class UsersController < ApplicationController
  before_filter :require_no_logined, :except => [:edit, :update, :destroy]
  before_filter :require_logined, :only => [:edit, :update, :destroy]

  def new
    @user = User.new
    store_location request.referrer if request.referrer.present?
  end

  def create
    @user = User.new user_params
    if @user.save
      login_as @user
      redirect_back_or_default root_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    if current_user.check_current_password(update_user_params[:current_password]) && current_user.update_attributes(update_user_params)
      redirect_to account_url
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:name, :email, :password, :current_password).delete_if { |key, value| value.empty? }
  end
end
