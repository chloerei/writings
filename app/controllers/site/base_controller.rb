class Site::BaseController < ApplicationController
  layout 'site'
  before_filter :require_site, :set_title

  private

  def require_site
    if request.host =~ /^\w+\.#{APP_CONFIG["host"]}$/
      @user = User.find_by(:name => /^#{request.subdomain(DOMAIN_LENGTH)}$/i)

      redirect_to url_for(:host => @user.domain) if @user.domain.present?
    else
      @user = User.find_by(:domain => request.host)
    end
  end

  def set_title
    append_title @user.display_name
  end
end
