class Site::ArticlesController < Site::BaseController
  def index
    @articles = @user.articles.desc(:created_at).page(params[:page]).per(5)
  end

  def show
    @article = @user.articles.find_by :number_id => params[:id]
  end
end
