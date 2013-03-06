class Site::ArticlesController < Site::BaseController
  def index
    @articles = @user.articles.publish.desc(:created_at).page(params[:page]).per(10)
  end

  def show
    @article = @user.articles.publish.find_by :token => params[:id]

    if params[:urlname].to_s != @article.urlname.to_s
      redirect_to site_article_path(@article, :urlname => @article.urlname)
    end
  end

  def feed
    @articles = @user.articles.publish.desc(:created_at).limit(20)
    @feed_title = @user.profile.name.present? ? @user.profile.name : @user.name
    @feed_link = site_root_url

    respond_to do |format|
      format.rss
    end
  end
end
