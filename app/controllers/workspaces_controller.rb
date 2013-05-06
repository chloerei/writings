class WorkspacesController < ApplicationController
  before_filter :require_logined
  before_filter :check_workspace_limit, :only => [:new, :create]
  layout 'dashboard'

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = current_user.own_workspaces.new workspace_params
    @workspace.save
    respond_to do |format|
      format.js
    end
  end

  private

  def check_workspace_limit
    unless current_user.own_workspaces.count < current_user.workspace_limit
      render :limit
    end
  end

  def workspace_params
    params.require(:workspace).permit(:name, :full_name)
  end
end
