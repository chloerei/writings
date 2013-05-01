class Dashboard::ArticlesController < Dashboard::BaseController
  before_filter :find_article, :only => [:edit, :update, :trash, :restore]

  def index
    @articles = @space.articles.desc(:updated_at).page(params[:page]).status(params[:status]).includes(:category)

    if params[:category_id] && @category = @space.categories.where(:urlname => params[:category_id]).first
      @articles = @articles.where(:category_id => @category.id)
    end

    append_title I18n.t('all_articles')
    append_title I18n.t(params[:status]) if params[:status].present?
  end

  def new
    @article = @space.articles.new
    if params[:category_id]
      @article.category = @space.categories.where(:urlname => params[:category_id]).first
    end
    append_title @article.title
    render :edit, :layout => false
  end

  def create
    @article = @space.articles.new article_params
    if @article.save
      @article.create_version

      respond_to do |format|
        format.json { render :json => article_as_json(@article) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => @article.errors.full_messages.join }, :status => 400 }
      end
    end
  end

  def edit
    append_title @article.title
    render :layout => false
  end

  def update
    if article_params[:save_count].to_i > @article.save_count
      if @article.update_attributes article_params

        if @article.save_count - @article.last_version_save_count >= 100
          @article.create_version
        end

        respond_to do |format|
          format.json { render :json => article_as_json(@article) }
        end
      else
        respond_to do |format|
          format.json { render :json => { :message => @article.errors.full_messages.join }, :status => 400 }
        end
      end
    else
      respond_to do |format|
        format.json { render :json => article_as_json(@article) }
      end
    end
  end

  def trash_index
    @articles = @space.articles.desc(:updated_at).page(params[:page]).status('trash').includes(:category)
  end

  def empty_trash
    @space.articles.trash.delete_all

    respond_to do |format|
      format.js
    end
  end

  def trash
    @article.update_attribute :status, 'trash'
    redirect_to dashboard_articles_url
  end

  def restore
    @article.update_attribute :status, 'draft'
    redirect_to edit_dashboard_article_url(@article)
  end

  private

  def find_article
    @article = @space.articles.find_by(:token => params[:id])
  end

  def article_params
    base_params = params.require(:article).permit(:title, :body, :urlname, :status, :save_count)

    if params[:article][:category_id]
      base_params.merge!(:category => @space.categories.where(:urlname => params[:article][:category_id]).first)
    end

    base_params
  end

  def article_as_json(article)
    article.as_json(:only => [:urlname, :title, :status, :token, :save_count]).merge(:url => site_article_url(article, :urlname => article.urlname, :host => @space.host), :updated_at => article.updated_at.to_s)
  end
end
