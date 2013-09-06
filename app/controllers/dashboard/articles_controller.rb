class Dashboard::ArticlesController < Dashboard::BaseController
  before_filter :find_article, :only => [:show, :status, :edit, :update, :restore]
  before_filter :find_articles, :only => [:batch_trash, :batch_publish, :batch_draft, :batch_restore, :batch_destroy]
  before_filter :check_lock_status, :only => [:update]

  def index
    @articles = @space.articles.desc(:updated_at).page(params[:page]).per(15).untrash

    if params[:status].present?
      @articles = @articles.status(params[:status])
    elsif !@space.in_plan?(:free) && params[:query].present?
      query = params[:query].split.map { |string| Regexp.escape string }[0..2].join '|'
      @articles = @articles.where(:title => /#{query}/i)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def trashed
    @articles = @space.articles.desc(:updated_at).page(params[:page]).per(15).status('trash')
  end

  def show
    respond_to do |format|
      format.md { render :text => PandocRuby.convert(@article.body, { :from => 'html', :to => 'markdown+hard_line_breaks' }, 'atx-headers') }
    end
  end

  def new
    @article = @space.articles.new
    append_title @article.title
    render :edit, :layout => 'editor'
  end

  def create
    @article = @space.articles.new article_params.merge(:user => current_user, :last_edit_user => current_user)
    if @article.save
      @article.create_version

      render :article
    else
      render :json => { :message => @article.errors.full_messages.join }, :status => 400
    end
  end

  def status
  end

  def edit
    append_title @article.title

    render :layout => 'editor'
  end

  def update
    if @article.last_edit_user && @article.last_edit_user != current_user
      @article.create_version :user => @article.last_edit_user
    end

    if article_params[:save_count].to_i > @article.save_count
      if @article.update_attributes article_params.merge(:last_edit_user => current_user)

        if @article.save_count - @article.last_version_save_count >= 100
          @article.create_version :user => current_user
        end

        render :article
      else
        respond_to do |format|
          format.json { render :json => { :message => @article.errors.full_messages.join }, :status => 400 }
        end
      end
    else
      render :json => { :message => I18n.t('save_count_expired'), :code => 'save_count_expired' }, :status => 400
    end
  end

  def restore
    @article.update_attributes :status => :draft
    redirect_to :action => :edit, :id => @article
  end

  def empty_trash
    @space.articles.trash.destroy_all
  end

  def batch_trash
    @articles.untrash.update_all :status => 'trash', :updated_at => Time.now.utc

    render :batch_update
  end

  def batch_publish
    @articles.untrash.update_all :status => 'publish', :updated_at => Time.now.utc
    @articles.untrash.where(:published_at => nil).update_all :published_at => Time.now.utc

    render :batch_update
  end

  def batch_draft
    @articles.untrash.update_all :status => 'draft', :updated_at => Time.now.utc

    render :batch_update
  end

  def batch_restore
    @articles.trash.where(:status => 'trash').update_all :status => 'draft', :updated_at => Time.now.utc

    render :batch_update
  end

  def batch_destroy
    @articles.trash.destroy_all

    render :batch_update
  end

  private

  def find_article
    @article = @space.articles.find_by(:token => params[:id])
  end

  def find_articles
    @articles = @space.articles.where(:token.in => params[:ids])
  end

  def article_params
    base_params = params.require(:article).permit(:title, :body, :urlname, :status, :save_count)

    base_params
  end

  def check_lock_status
    if @article.locked? and !@article.locked_by?(current_user)
      locked_user = User.where(:id => @article.locked_by).first
      render :json => { :message => I18n.t('is_editing', :name => @article.locked_by_user.name ), :code => 'article_locked', :locked_user => { :name => locked_user.try(:name) } }, :status => 400
    else
      @article.lock_by(current_user)
    end
  end
end
