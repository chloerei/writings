class UserSessionsController < ApplicationController
  layout 'home'
  before_filter :require_no_logined, :except => :destroy
  after_filter :inc_ip_count, :only => :create
  helper_method :require_recaptcha?

  def new
    store_location request.referrer if request.referrer.present?
  end

  def create
    if !require_recaptcha? || verify_recaptcha
      login = params[:login].strip

      user = if login.include?('@')
               User.where(:email => /^#{Regexp.escape login}$/i).first
             else
               User.where(:name => login.downcase).first
             end

      if user and user.authenticate(params[:password])
        login_as user
        remember_me if params[:remember_me]
      else
        flash[:error] = I18n.t('errors.messages.wrong_name_or_password')
      end
    else
      flash[:error] = I18n.t('recaptcha.errors.verification_failed')
    end
  end

  def destroy
    logout
  end

  private

  def inc_ip_count
    Rails.cache.write "login/#{request.remote_ip}", ip_count + 1, :expires_in => 60.seconds
  end

  def ip_count
    Rails.cache.read("login/#{request.remote_ip}").to_i
  end

  def require_recaptcha?
    ip_count >= 3
  end
end
