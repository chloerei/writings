class Dashboard::DiscussionsController < Dashboard::BaseController
  def index
    @discussions = @space.discussions.desc(:updated_at).page(params[:page])
  end
end
