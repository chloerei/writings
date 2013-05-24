class Dashboard::DiscussionsController < Dashboard::BaseController
  def index
    @discussions = @space.discussions.opening.desc(:updated_at).page(params[:page])
  end

  def archived
    @discussions = @space.discussions.archived.desc(:updated_at).page(params[:page])
    render :index
  end
end
