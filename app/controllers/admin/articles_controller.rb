class Admin::ArticlesController < Admin::BaseController
  def index
    @articles = case params[:tab]
    when 'all'
      Article.desc(:updated_at).includes(:user).page(params[:page]).per(25)
    else
      Article.publish.desc(:published_at).includes(:user).page(params[:page]).per(25)
    end

    if params[:name] && user = User.where(:name => params[:name]).first
      @articles = @articles.where(:user_id => user.id)
    end
  end

  def show
    @article = Article.find params[:id]
  end
end
