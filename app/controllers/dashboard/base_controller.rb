class Dashboard::BaseController < ApplicationController
  before_filter :require_logined
  before_filter :find_space, :require_space_access
  helper_method :is_creator?
  layout 'dashboard'

  private

  class AccessDenied < Exception
  end

  def find_space
    @space = Space.find_by :name => params[:space_id]
  end

  def require_space_access
    unless @space.user == current_user or (!@space.in_plan?(:free) && @space.members.include?(current_user))
      raise AccessDenied
    end
  end

  def require_creator
    unless is_creator?
      raise AccessDenied
    end
  end

  def is_creator?
    @space.user == current_user
  end
end
