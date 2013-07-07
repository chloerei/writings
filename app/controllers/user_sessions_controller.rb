class UserSessionsController < ApplicationController
  layout 'dashboard_base'
  before_filter :require_no_logined, :except => :destroy

  def new
    store_location request.referrer if request.referrer.present?
  end

  def create
    login = /^#{params[:login]}$/i
    user = User.any_of({:name => login}, {:email => login}).first
    if user and user.authenticate(params[:password])
      login_as user
      remember_me if params[:remember_me]
    end
  end

  def destroy
    logout
  end
end
