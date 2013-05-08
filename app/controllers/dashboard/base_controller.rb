class Dashboard::BaseController < ApplicationController
  before_filter :require_logined
  before_filter :find_space, :require_space_access
  before_filter :set_base_title
  helper_method :is_workspace_creator?
  layout 'dashboard'

  private

  class AccessDenied < Exception
  end

  def find_space
    @space = Space.find_by :name => /^#{params[:space_id]}$/i
  end

  def require_space_access
    case @space
    when User
      unless @space == current_user
        raise AccessDenied
      end
    when Workspace
      unless @space.members.include?(current_user)
        raise AccessDenied
      end
    else
      raise AccessDenied
    end
  end

  def set_base_title
    append_title APP_CONFIG['site_name']
  end

  def require_workspace
    unless @space.is_a?(Workspace)
      redirect_to dashboard_root_path
    end
  end

  def require_creator
    unless @space.is_a?(Workspace) && @space.creator == current_user
      raise AccessDenied
    end
  end

  def is_workspace_creator?
    @space.is_a?(Workspace) && @space.creator == current_user
  end
end
