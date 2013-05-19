class Dashboard::DiscussionsController < Dashboard::BaseController
  def index
    @discussions = @space.discussions.page(params[:page])
  end
end
