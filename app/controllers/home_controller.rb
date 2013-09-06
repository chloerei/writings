class HomeController < ApplicationController
  layout 'home'
  before_filter :logined_redirect

  private

  def logined_redirect
    if logined?
      if space = current_user.spaces.asc(:created_at).first
        redirect_to dashboard_root_path(space)
      else
        redirect_to new_space_path
      end
    end
  end
end
