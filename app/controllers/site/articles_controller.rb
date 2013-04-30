class Site::ArticlesController < Site::BaseController
  def index
    @articles = @user.articles.publish.desc(:published_at).page(params[:page]).per(5)
  end

  def show
    @article = @user.articles.publish.where(:token => params[:id]).first

    if @article
      # urlname not match redirect
      if params[:urlname].to_s != @article.urlname.to_s
        redirect_to site_article_path(@article, :urlname => @article.urlname), :status => 301
      end
    else
      # old url redirect
      @article = @user.articles.publish.find_by(:old_url => params[:id])
      redirect_to site_article_path(@article, :urlname => @article.urlname), :status => 301
    end
  end

  def feed
    @articles = @user.articles.publish.desc(:published_at).limit(20)
    @feed_title = @user.profile.name.present? ? @user.profile.name : @user.name
    @feed_link = site_root_url

    respond_to do |format|
      format.rss
    end
  end
end
