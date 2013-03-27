class Admin::ArticlesController < Admin::BaseController
  def index
    @articles_scope = Article.scoped
    if params[:name] && @user = User.where(:name => params[:name]).first
      @articles_scope = @articles_scope.where(:user_id => @user.id)
    end

    @articles = case params[:tab]
                when 'all'
                  @articles_scope.desc(:updated_at).includes(:user).page(params[:page]).per(25)
                else
                  @articles_scope.publish.desc(:published_at).includes(:user).page(params[:page]).per(25)
                end
  end

  def show
    @article = Article.find params[:id]
  end
end
