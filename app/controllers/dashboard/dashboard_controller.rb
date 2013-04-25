class Dashboard::DashboardController < Dashboard::BaseController
  skip_filter :require_logined, :only => :show

  def show
    if logined?
      @articles = current_user.articles.desc(:updated_at).limit(5)
    else
      render :guest_index
    end
  end
end
