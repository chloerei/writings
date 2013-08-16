class HomeController < ApplicationController
  layout 'dashboard_base'
  before_filter :logined_redirect, :except => [:about, :read_blog]
  before_filter :require_logined, :only => [:read_blog]

  def read_blog
    current_user.update_attribute :read_blog_at, Time.now.utc
    render :nothing => true
  end

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
