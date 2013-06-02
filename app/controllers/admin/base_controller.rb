class Admin::BaseController < ApplicationController
  before_filter :require_logined
  before_filter :require_admin
  before_filter :set_base_title
  layout 'admin'

  private

  def require_admin
    unless current_user.admin?
      render_404
    end
  end

  def set_base_title
    append_title APP_CONFIG['site_name']
    append_title 'admin'
  end
end
