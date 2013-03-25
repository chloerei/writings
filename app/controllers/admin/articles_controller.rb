class Admin::ArticlesController < Admin::BaseController
  def index
    case params[:tab]
    when 'all'
      @articles = Article.desc(:updated_at).includes(:user).page(params[:page]).per(25)
    else
      @articles = Article.publish.desc(:published_at).includes(:user).page(params[:page]).per(25)
    end
  end

  def show
    @article = Article.find params[:id]
  end
end
