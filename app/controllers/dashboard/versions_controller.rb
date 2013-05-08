class Dashboard::VersionsController < Dashboard::BaseController
  def index
    @article = @space.articles.find_by :token => params[:article_id]
    if @space.in_plan?(:free)
      @versions = @article.versions.includes(:user).page(1).limit(5)
    else
      @versions = @article.versions.includes(:user).page(params[:page]).per(20)
    end
  end

  def show
    @article = @space.articles.find_by :token => params[:article_id]
    @version = @article.versions.find params[:id]
    respond_to do |format|
      format.json { render :json => @version.as_json(:only => [:title, :body, :created_at]) }
    end
  end

  def restore
    @article = @space.articles.find_by :token => params[:article_id]
    @version = @article.versions.find params[:id]

    @article.create_version
    @article.update_attributes(:title => @version.title,
                               :body  => @version.body)
  end
end
