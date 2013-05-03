class AccountsController < ApplicationController
  before_filter :require_logined, :set_need_current_password
  layout 'dashboard'

  def edit
  end

  def update
    if current_user.update_attributes(user_params)
      respond_to do |format|
        format.json { render :json => current_user.as_json(:only => [:name, :email], :methods => [:host]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => current_user.errors.full_messages.join }, :status => 400}
      end
    end
  end

  private
  def set_need_current_password
    current_user.need_current_password = true
  end

  def user_params
    params.require(:user).permit(:name, :email, :domain, :disqus_shortname, :locale, :password, :password_confirmation, :current_password).delete_if { |key, value| key =~ /password/ && value.empty? }
  end
end
