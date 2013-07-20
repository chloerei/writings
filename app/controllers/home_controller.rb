class HomeController < ApplicationController
  layout 'dashboard_base'
  before_filter :logined_redirect, :except => [:about]

  private

  def logined_redirect
    if logined?
      redirect_to dashboard_root_path(current_user)
    end
  end
end
