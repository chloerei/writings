class Dashboard::DashboardController < Dashboard::BaseController
  skip_filter :require_logined, :only => :show

  def show
    @articles = @space.articles.status(nil).desc(:updated_at).limit(10)
    @attachments = @space.attachments.desc(:created_at).limit(5)
  end
end
