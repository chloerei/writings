class Site::ArticlesController < Site::BaseController
  def index
    @articles = @user.articles.desc(:created_at).page(params[:page]).per(5)
  end
end
