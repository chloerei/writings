class UsersController < ApplicationController
  layout 'dashboard_base'
  before_filter :require_no_logined

  def new
    @user = User.new
    referrer = request.headers['X-XHR-Referer'] || request.referrer
    store_location referrer if referrer.present?
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
  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
