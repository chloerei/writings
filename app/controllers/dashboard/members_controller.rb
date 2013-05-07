class Dashboard::MembersController < Dashboard::BaseController
  before_filter :require_workspace

  def index
  end

  def destroy
    @member = @space.members.find_by :name => params[:id]
    @space.members.delete @member

    respond_to do |format|
      format.js
    end
  end
end
