class UiController < ApplicationController
  layout 'dashboard'

  def site_home
    render :layout => 'site'
  end
end
