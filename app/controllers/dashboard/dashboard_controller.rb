class Dashboard::DashboardController < Dashboard::BaseController
  def show
    @articles = current_user.articles.desc(:updated_at).limit(5)
  end
end
