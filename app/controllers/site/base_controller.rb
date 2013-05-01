class Site::BaseController < ApplicationController
  layout 'site'
  before_filter :require_space, :set_title

  private

  def require_space
    if request.host =~ /^\w+\.#{APP_CONFIG["host"]}$/
      @space = Space.find_by(:name => /^#{request.subdomain(DOMAIN_LENGTH)}$/i)

      redirect_to url_for(:host => @space.domain) if @space.domain.present?
    else
      @space = Space.find_by(:domain => request.host)
    end
  end

  def set_title
    append_title @space.display_name
  end
end
