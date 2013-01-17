class Site::ArticlesController < Site::BaseController
  def index
    @articles = @user.articles.desc(:created_at).page(params[:page]).per(5)
  end

  def show
    @article = @user.articles.find_by :number_id => params[:id]
  end

  def feed
    @articles = @user.articles.desc(:created_at).limit(20)
    @feed_title = @user.profile.name.present? ? @user.profile.name : @user.name
    @feed_link = site_root_url

    respond_to do |format|
      format.rss
    end
  end
end
