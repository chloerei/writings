class UserSessionsController < ApplicationController
  layout 'dashboard'
  before_filter :require_no_logined, :except => :destroy

  def new
    referrer = request.headers['X-XHR-Referer'] || request.referrer
    store_location referrer if referrer.present?
  end

  def create
    login = /^#{params[:login]}$/i
    user = User.any_of({:name => login}, {:email => login}).first
    if user and user.authenticate(params[:password])
      login_as user
      remember_me if params[:remember_me]
      redirect_back_or_default dashboard_root_url(user)
    else
      flash[:error] = 'Wrong login name or password'
      redirect_to login_url
    end
  end

  def destroy
    logout
    redirect_to request.referrer || root_url
  end
end
