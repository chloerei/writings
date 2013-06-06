class Admin::ArticlesController < Admin::BaseController
  def index
    @articles_scope = Article.scoped
    if params[:name]
      @space = Space.where(:name => params[:name]).first
      @articles_scope = @articles_scope.where(:space_id => (@space ? @space.id : nil))
    end

    @articles = case params[:tab]
                when 'all'
                  @articles_scope.desc(:updated_at).includes(:space).page(params[:page]).per(25)
                else
                  @articles_scope.publish.desc(:published_at).includes(:space).page(params[:page]).per(25)
                end
  end

  def show
    @article = Article.find params[:id]
  end
end
