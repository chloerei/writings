class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :logined?, :current_user, :append_title, :page_title
  before_filter :set_locale, :set_base_title

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404
  end

  protected

  def set_base_title
    append_title APP_CONFIG['site_name']
  end

  def param_to_token(param)
    param.split('-').first
  end

  def render_404
    render 'errors/404', :layout => 'error', :status => 404
  end

  def render_500(e)
    logger.info e
    render 'errors/500', :layout => 'error', :status => 500
  end

  def append_title(title)
    @page_title ||= []
    @page_title << title
  end

  def page_title
    @page_title.to_a.reverse.join(' - ')
  end

  def set_locale
    I18n.locale = set_locale_from_user || set_locale_from_accept_language_header || I18n.default_locale
  end

  def set_locale_from_user
    current_user.try(:locale)
  end

  def set_locale_from_accept_language_header
    request.compatible_language_from(ALLOW_LOCALE)
  end

  def require_logined
    unless logined?
      store_location
      redirect_to login_url
    end
  end

  def require_no_logined
    if logined?
      redirect_to root_url
    end
  end

  def current_user
    @current_user ||= login_from_session || login_from_cookies unless defined?(@current_user)
    @current_user
  end

  def logined?
    !!current_user
  end

  def login_as(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def logout
    session.delete(:user_id)
    @current_user = nil
    forget_me
  end

  def login_from_session
    if session[:user_id].present?
      begin
        User.find session[:user_id]
      rescue
        session[:user_id] = nil
      end
    end
  end

  def login_from_cookies
    if cookies[:remember_token].present?
      if user = User.find_by_remember_token(cookies[:remember_token])
        session[:user_id] = user.id
        user
      else
        forget_me
        nil
      end
    end
  end

  def login_from_access_token
    @current_user ||= User.find_by_access_token(params[:access_token]) if params[:access_token]
  end

  def store_location(path = nil)
    session[:return_to] = path || request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_referrer_or_default(default)
    redirect_to(request.referrer || default)
  end

  def forget_me
    cookies.delete(:remember_token)
  end

  def remember_me
    cookies[:remember_token] = {
      :value   => current_user.remember_token,
      :expires => 2.weeks.from_now
    }
  end
end
