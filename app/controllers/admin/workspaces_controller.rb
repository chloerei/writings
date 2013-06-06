class Admin::WorkspacesController < Admin::BaseController
  def index
    @workspaces = Workspace.desc(:created_at).page(params[:page]).per(25)
  end

  def show
    @workspace = Workspace.find_by :name => /\A#{params[:id]}\z/i
  end
end
