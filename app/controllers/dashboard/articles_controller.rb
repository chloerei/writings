class Dashboard::ArticlesController < Dashboard::BaseController
  before_filter :find_article, :only => [:show, :status, :edit, :update, :trash, :restore, :publish, :draft, :category]
  before_filter :check_lock_status, :only => [:update]

  def index
    @articles = @space.articles.desc(:updated_at).page(params[:page]).per(15).status(params[:status]).includes(:category)

    append_title I18n.t('articles')

    if params[:category_id]
      if params[:category_id] == 'none'
        @articles = @articles.where(:category_id => nil)

        append_title I18n.t('not_category')
      else
        @category = @space.categories.where(:urlname => params[:category_id]).first
        @articles = @articles.where(:category_id => @category.try(:id) || -1)

        append_title @category.name if @category
      end
    end

    append_title I18n.t(params[:status]) if params[:status].present?
  end

  def show
    basename = "#{@article.token}-#{@article.urlname}"
    respond_to do |format|
      format.md { send_data(PandocRuby.convert(@article.body, { :from => :html, :to => 'markdown+hard_line_breaks'}, 'atx-headers'),
                            :filename => "#{basename}.md") }
      format.docx do
        send_file(ArticleExporter.new(@article).build_docx,
                  :filename => "#{basename}.docx")
      end

      format.odt do
        send_file(ArticleExporter.new(@article).build_odt,
                  :filename => "#{basename}.odt")
      end
    end
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
    @article = @space.articles.new article_params.merge(:last_edit_user => current_user)
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

    if params[:note_id]
      @note = @article.notes.where(:token => params[:note_id]).first
    end

    render :layout => false
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

  def trash_index
    @articles = @space.articles.desc(:updated_at).page(params[:page]).status('trash').includes(:category)
  end

  def empty_trash
    @space.articles.trash.delete_all
  end

  def category
    @article.category = @space.categories.find_by(:urlname => params[:article][:category_id])
    @article.save
    render :update
  end

  def trash
    @article.update_attribute :status, 'trash'
    respond_to do |format|
      format.html { redirect_to dashboard_articles_url }
      format.js { render :remove }
    end
  end

  def restore
    @article.update_attribute :status, 'draft'
    respond_to do |format|
      format.html { redirect_to edit_dashboard_article_url(@space, @article) }
      format.js { render :remove }
    end
  end

  def publish
    @article.update_attribute :status, 'publish'
    render :update
  end

  def draft
    @article.update_attribute :status, 'draft'
    render :update
  end

  def destroy
    @article = @space.articles.trash.find_by(:token => params[:id])
    @article.destroy
    render :remove
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

  def check_lock_status
    if @article.locked? and !@article.locked_by?(current_user)
      locked_user = User.where(:id => @article.locked_by).first
      render :json => { :message => I18n.t('is_editing', :name => @article.locked_by_user.name ), :code => 'article_locked', :locked_user => { :name => locked_user.try(:name) } }, :status => 400
    else
      @article.lock_by(current_user)
    end
  end
end
