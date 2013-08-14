class Dashboard::MembersController < Dashboard::BaseController
  before_filter :require_plan, :only => [:destroy]

  def index
  end

  def destroy
    @member = @space.members.find_by :name => params[:id]
    @space.members.delete @member
  end

  private

  def require_plan
    if @space.in_plan?(:free)
      render :js => "Turbolinks.visit('#{dashboard_members_url(@space)}');"
    end
  end
end
