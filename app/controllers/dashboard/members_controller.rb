class Dashboard::MembersController < Dashboard::BaseController
  def index
  end

  def destroy
    @member = @space.members.find_by :name => params[:id]
    @space.members.delete @member
  end
end
