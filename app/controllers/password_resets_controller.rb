class PasswordResetsController < ApplicationController
  layout 'home'
  before_filter :require_no_logined
  after_filter :inc_ip_count, :only => :create
  helper_method :require_recaptcha?

  def new
  end

  def create
    if !require_recaptcha? || verify_recaptcha(:model => @user)
      @user = User.where(:email => /^#{Regexp.escape params[:email]}$/i).first
      if @user
        @user.generate_password_reset_token
        SystemMailer.delay.password_reset(@user.id.to_s)
        flash[:info] = I18n.t(:password_reset_email_send)
      else
        flash[:error] = I18n.t(:password_reset_email_no_found)
      end
    else
      flash[:error] = I18n.t('recaptcha.errors.verification_failed')
    end
  end

  def edit
    @user = User.where(:password_reset_token => params[:id]).first

    if @user && @user.password_reset_token_created_at > 2.hours.ago
      @user.in_password_reset = true
      render :edit
    else
      flash[:error] = I18n.t(:password_reset_not_found_or_expired)
      redirect_to new_password_reset_url
    end
  end

  def update
    @user = User.find_by(:password_reset_token => params[:id])
    @user.in_password_reset = true
    if @user.update_attributes params.require(:user).permit(:password, :password_confirmation)
      @user.unset_password_reset_token
      flash[:success] = I18n.t(:password_reset_success)
    end
  end

  private

  def inc_ip_count
    Rails.cache.write "password_reset_count/#{request.remote_ip}", ip_count + 1, :expires_in => 60.seconds
  end

  def ip_count
    Rails.cache.read("password_reset_count/#{request.remote_ip}").to_i
  end

  def require_recaptcha?
    ip_count >= 3
  end
end
