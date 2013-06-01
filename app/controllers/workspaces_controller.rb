class WorkspacesController < ApplicationController
  before_filter :require_logined
  before_filter :check_workspace_limit, :only => [:new, :create]
  layout 'dashboard'

  def new
    @workspace = Workspace.new :name => "#{current_user.name}-workspace-#{current_user.creator_workspaces.count + 1}"
  end

  def create
    @workspace = current_user.creator_workspaces.new workspace_params
    @workspace.save
  end

  private

  def check_workspace_limit
    unless current_user.creator_workspaces.count < current_user.workspace_limit
      respond_to do |format|
        format.html { render :limit }
        format.js { render :js => '' }
      end
    end
  end

  def workspace_params
    params.require(:workspace).permit(:name, :full_name)
  end
end
