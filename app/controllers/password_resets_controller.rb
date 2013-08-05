class PasswordResetsController < ApplicationController
  layout 'dashboard_base'
  before_filter :require_no_logined

  def new
  end

  def create
    @user = User.where(:email => params[:email]).first
    if @user
      redirect_to login_url
    else
      render :new
    end
  end
end
