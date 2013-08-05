class PasswordResetsController < ApplicationController
  layout 'dashboard_base'
  before_filter :require_no_logined

  def new
  end

  def create
    @user = User.where(:email => params[:email]).first
    if @user
      @user.generate_password_reset_token
      SystemMailer.delay.password_reset(@user.id.to_s)
      flash[:info] = I18n.t(:password_reset_email_send)
    else
      flash[:error] = I18n.t(:password_reset_email_no_found)
    end
  end
end
