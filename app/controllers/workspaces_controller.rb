class WorkspacesController < ApplicationController
  before_filter :require_logined
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

  def workspace_params
    params.require(:workspace).permit(:name, :full_name)
  end
end
