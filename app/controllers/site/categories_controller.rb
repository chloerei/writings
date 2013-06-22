class Site::CategoriesController < Site::BaseController
  def index
    @categories = @space.categories
  end

  def show
    @category = @space.categories.find_by :token => param_to_token(params[:id])
    @articles = @category.articles.publish.desc(:created_at).page(params[:page]).per(5)
  end

  def feed
    @category = @space.categories.find_by :token => param_to_token(params[:id])
    @articles = @category.articles.publish.desc(:published_at).limit(20)
    @feed_title = "#{@category.name} - #{@space.display_name}"
    @feed_link = site_category_url(@category)

    respond_to do |format|
      format.rss { render 'site/articles/feed' }
    end
  end
end
