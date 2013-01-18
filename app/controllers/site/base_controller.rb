class Site::BaseController < ApplicationController
  layout 'site'
  before_filter :require_site

  private

  def require_site
    if request.host =~ /^\w+\.#{APP_CONFIG["host"]}$/
      @user = User.find_by(:name => /^#{request.subdomain(DOMAIN_LENGTH)}$/i)
    else
      @user = User.find_by(:domain => request.host)
    end
  end
end
