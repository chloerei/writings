class AccountsController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def show
    current_user.need_current_password = true
  end

  def update
    if current_user.authenticate user_params[:current_password]
      current_user.update_attributes(user_params)
    else
      current_user.errors.add(:current_password, I18n.t("errors.messages.is_not_match"))
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :full_name, :description, :email, :disqus_shortname, :locale, :password, :password_confirmation, :current_password).delete_if { |key, value| key =~ /password/ && value.empty? }
  end
end
