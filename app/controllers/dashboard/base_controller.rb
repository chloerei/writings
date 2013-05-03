class Dashboard::BaseController < ApplicationController
  before_filter :require_logined
  before_filter :find_space
  before_filter :set_base_title
  layout 'dashboard'

  private

  class AccessDenied < Exception
  end

  def find_space
    @space = Space.find_by :name => /^#{params[:space_id]}$/i

    case @space
    when User
      unless @space == current_user
        raise AccessDenied
      end
    when Workspace
      unless @space.owner == current_user or @space.members.include?(current_user)
        raise AccessDenied
      end
    else
      raise AccessDenied
    end
  end

  def set_base_title
    append_title APP_CONFIG['site_name']
  end
end
