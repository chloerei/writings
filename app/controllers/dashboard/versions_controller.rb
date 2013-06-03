class Dashboard::VersionsController < Dashboard::BaseController
  before_filter :find_article
  before_filter :check_lock_status, :only => [:restore]

  def index
    if @space.in_plan?(:free)
      @versions = @article.versions.includes(:user).page(1).limit(5)
    else
      @versions = @article.versions.includes(:user).page(params[:page]).per(20)
    end
  end

  def show
    @version = @article.versions.find params[:id]
      render :json => @version.as_json(:only => [:title, :body, :created_at])
  end

  def restore
    @version = @article.versions.find params[:id]

    @article.create_version
    @article.update_attributes(:title => @version.title,
                               :body  => @version.body)
    render :json => @version.as_json(:only => [:title, :body, :created_at])
  end

  private

  def find_article
    @article = @space.articles.find_by :token => params[:article_id]
  end

  def check_lock_status
    if @article.locked? and !@article.locked_by?(current_user)
      render :json => { :message => I18n.t('is_editing', :name => @article.locked_by_user.name ), :code => 'article_locked' }, :status => 400
    else
      @article.lock_by(current_user)
    end
  end
end
