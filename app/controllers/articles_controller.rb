class ArticlesController < ApplicationController
  before_filter :require_logined

  def index
    if logined?
      sleep(1)
      @articles = current_user.articles.desc(:created_at).limit(25).skip(params[:skip]).status(params[:status]).includes(:book)

      respond_to do |format|
        format.html
        format.js
      end
    else
      render :guest_index
    end
  end

  def book
    @book = current_user.books.find_by :urlname => params[:book_id]
    @articles = current_user.articles.where(:book_id => @book).desc(:created_at).limit(25).skip(params[:skip]).status(params[:status]).includes(:book)

    respond_to do |format|
      format.html { render :index }
      format.js { render :index }
    end
  end

  def not_collected
    @articles = current_user.articles.where(:book_id => nil).desc(:created_at).limit(25).skip(params[:skip]).status(params[:status]).includes(:book)

    respond_to do |format|
      format.html { render :index }
      format.js { render :index }
    end
  end

  def new
    @article = Article.new
    @article.id = nil
    if params[:book_id]
      @article.book = current_user.books.where(:urlname => params[:book_id]).first
    end
    render :edit, :layout => false
  end

  def create
    @article = current_user.articles.new article_params
    if @article.save
      respond_to do |format|
        format.json { render :json => @article.as_json(:only => [:urlname, :title, :status], :methods => :id) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => 'Validation Failed', :errors => @article.errors }, :status => 400 }
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
        format.json { render :json => @article.as_json(:only => [:urlname, :title, :status], :methods => :id) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => 'Validation Failed', :errors => @article.errors }, :status => 400 }
      end
    end
  end

  def bulk
    @articles = current_user.articles.where(:id.in => params.require(:ids))

    case params[:type]
    when 'move'
      book = current_user.books.where(:urlname => params[:book_id]).first
      @articles.update_all :book_id => book.try(:id)
    when 'publish'
      @articles.update_all :status => 'publish'
    when 'draft'
      @articles.update_all :status => 'draft'
    when 'trash'
      @articles.update_all :status => 'trash'
    when 'delete'
      @articles.trash.delete_all
    end

    respond_to do |format|
      format.json { render :json => @articles.includes(:book).as_json(:only => [:title, :urlname, :status], :methods => [:id, :book_name, :book_urlname]) }
    end
  end

  def empty_trash
    if params[:book_id]
      current_user.articles.where(:book_id => current_user.books.find_by(:urlname => params[:book_id])).trash.delete_all
    elsif params[:not_collected]
      current_user.articles.where(:book_id => nil).trash.delete_all
    else
      current_user.articles.trash.delete_all
    end

    respond_to do |format|
      format.json { render :json => [] }
    end
  end

  private

  def article_params
    base_params = params.require(:article).permit(:title, :body, :urlname, :status)

    if params[:article][:book_id]
      base_params.merge!(:book => current_user.books.where(:urlname => params[:article][:book_id]).first)
    end

    base_params
  end
end
