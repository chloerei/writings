class Dashboard::VersionsController < Dashboard::BaseController
  def index
    @article = current_user.articles.find_by :token => params[:article_id]
    @versions = @article.versions.includes(:user).page(params[:page]).per(20)
    respond_to do |format|
      format.js
    end
  end
end
