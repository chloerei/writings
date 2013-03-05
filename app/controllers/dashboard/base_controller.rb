class Dashboard::BaseController < ApplicationController
  before_filter :require_logined
  before_filter :set_base_title
  layout 'dashboard'

  private

  def set_base_title
    append_title APP_CONFIG['site_name']
  end
end
