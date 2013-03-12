class Site::CategoriesController < Site::BaseController
  def show
    @category = @user.categories.find_by :urlname => params[:id]
    @articles = @category.articles.publish.desc(:created_at).page(params[:page]).per(5)
  end

  def feed
    @category = @user.categories.find_by :urlname => params[:id]
    @articles = @category.articles.publish.desc(:published_at).limit(20)
    @feed_title = "#{@category.name} - #{@user.profile.name.present? ? @user.profile.name : @user.name}"
    @feed_link = site_category_url(@category)

    respond_to do |format|
      format.rss { render 'site/articles/feed' }
    end
  end
end
