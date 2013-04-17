class Dashboard::VersionsController < Dashboard::BaseController
  def index
    @article = current_user.articles.find_by :token => params[:article_id]
    @versions = @article.versions.includes(:user).page(params[:page]).per(20)
    respond_to do |format|
      format.js
    end
  end

  def show
    @article = current_user.articles.find_by :token => params[:article_id]
    @version = @article.versions.find params[:id]
    respond_to do |format|
      format.json { render :json => @version.as_json(:only => [:title, :body, :created_at]) }
    end
  end

  def restore
    @article = current_user.articles.find_by :token => params[:article_id]
    @version = @article.versions.find params[:id]

    @article.create_version
    @article.update_attributes(:title => @version.title,
                               :body  => @version.body)
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end
