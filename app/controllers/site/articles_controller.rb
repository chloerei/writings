class Site::ArticlesController < Site::BaseController
  def index
    @articles = @space.articles.publish.desc(:published_at).page(params[:page]).per(5)
  end

  def show
    @article = @space.articles.publish.where(:token => params[:id]).first

    # urlname not match redirect
    if params[:urlname].to_s != @article.urlname.to_s
      redirect_to site_article_path(@article, :urlname => @article.urlname), :status => 301
    end
  end

  def feed
    @articles = @space.articles.publish.desc(:published_at).limit(20)
    @feed_title = @space.display_name
    @feed_link = site_root_url

    respond_to do |format|
      format.rss
    end
  end
end
