class Site::BaseController < ApplicationController
  layout 'site'
  before_filter :require_site

  private

  def require_site
    @user = User.find_by(:name => /^#{request.subdomain(DOMAIN_LENGTH)}$/i)
  end
end
