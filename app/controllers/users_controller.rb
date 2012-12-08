class UsersController < ApplicationController
  before_filter :require_no_logined

  def new
    @user = User.new
    store_location request.referrer if request.referrer.present?
  end

  def create
    @user = User.new params[:user]
    if @user.save
      login_as @user
      redirect_back_or_default root_url
    else
      render :new
    end
  end
end
