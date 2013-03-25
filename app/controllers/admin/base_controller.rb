class Admin::BaseController < ApplicationController
  before_filter :require_logined
  before_filter :require_admin
  layout 'admin'

  private

  def require_admin
    unless APP_CONFIG['admin_emails'].include?(current_user.email)
      render_404
    end
  end
end
