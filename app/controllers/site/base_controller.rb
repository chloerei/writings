class Site::BaseController < ApplicationController
  layout 'site'
  skip_filter :set_base_title
  before_filter :require_space, :set_site_title

  private

  def require_space
    if request.host =~ /^[a-z0-9-]+\.#{Regexp.escape APP_CONFIG["host"]}$/
      @space = Space.find_by(:name => request.subdomain(DOMAIN_LENGTH))

      if @space.domain_enabled? && @space.domain.present?
        redirect_to url_for(:host => @space.domain)
      end
    else
      @space = Space.find_by(:domain => request.host)

      if !@space.domain_enabled?
        redirect_to url_for(:host => @space.host)
      end
    end
  end

  def set_site_title
    append_title @space.display_name
  end
end
