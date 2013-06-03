class WorkspacesController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def new
    @workspace = Workspace.new :name => "#{current_user.name}-workspace-#{current_user.creator_workspaces.count + 1}"
  end

  def create
    if current_user.creator_workspaces.count < current_user.workspace_limit
      @workspace = current_user.creator_workspaces.new workspace_params
      @workspace.save
    else
      render :js => ''
    end
  end

  private

  def workspace_params
    params.require(:workspace).permit(:name, :full_name)
  end
end
