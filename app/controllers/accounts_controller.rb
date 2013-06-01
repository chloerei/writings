class AccountsController < ApplicationController
  before_filter :require_logined, :set_need_current_password
  layout 'dashboard'

  def edit
  end

  def update
    current_user.update_attributes(user_params)
  end

  private
  def set_need_current_password
    current_user.need_current_password = true
  end

  def user_params
    params.require(:user).permit(:email, :domain, :disqus_shortname, :locale, :password, :password_confirmation, :current_password).delete_if { |key, value| key =~ /password/ && value.empty? }
  end
end
