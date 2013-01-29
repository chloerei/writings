class Dashboard::BaseController < ApplicationController
  before_filter :require_logined
  before_filter :set_base_title
  layout 'dashboard'

  private

  def set_base_title
    if logined?
      append_title current_user.name
    end
  end
end
