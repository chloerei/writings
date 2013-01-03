class ArticlesController < ApplicationController
  before_filter :require_logined

  def index
    if logined?
      @articles = current_user.articles.desc(:created_at)

      case params[:status]
      when 'publish'
        @articles = @articles.publish
      when 'draft'
        @articles = @articles.draft
      end

      if params[:book_id].present?
        @book = current_user.books.where(:urlname => params[:book_id].to_s).first
        @articles = @articles.where(:book_id => @book.try(:id))
      elsif params[:not_collected]
        @articles = @articles.where(:book_id => nil)
      end

    else
      render :guest_index
    end
  end

  def new
    @article = Article.new
    render :edit
  end

  def create
    @article = current_user.articles.new article_params
    if @article.save
      respond_to do |format|
        format.json { render :json => @article.as_json(:only => [:urlname, :title, :publish], :methods => :id) }
      end
    else
      respond_to do |format|
        format.json { render :text => @article.errors.full_messages, :status => :error }
      end
    end
  end

  def edit
    @article = current_user.articles.find(params[:id])
    render :layout => false
  end

  def update
    @article = current_user.articles.find params[:id]
    if @article.update_attributes article_params
      respond_to do |format|
        format.json { render :json => @article.as_json(:only => [:urlname, :title, :publish], :methods => :id) }
      end
    else
      respond_to do |format|
        format.json { render :text => @article.errors.full_messages, :status => :error }
      end
    end
  end

  private

  def article_params
    base_params = params.require(:article).permit(:title, :body, :urlname, :publish)

    if params[:article][:book_id] and book = current_user.books.where(:urlname => params[:article][:book_id]).first
      base_params.merge!(:book => book)
    end

    base_params
  end
end
