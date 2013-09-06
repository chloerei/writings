class UsersController < ApplicationController
  layout 'home'
  before_filter :require_no_logined

  def new
    @user = User.new :password => 1 # force client side validation patch
    referrer = request.headers['X-XHR-Referer'] || request.referrer
    store_location referrer if referrer.present?
  end

  def create
    @user = User.new user_params
    if @user.save
      login_as @user
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
