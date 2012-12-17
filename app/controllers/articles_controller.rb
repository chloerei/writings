class ArticlesController < ApplicationController
  before_filter :require_logined
  before_filter :find_book, :only => [:new, :create]

  def new
    @article = @book.articles.new
    @article.id = nil
    render :editor, :layout => false
  end

  def create
    @article = @book.articles.new article_params.merge(:user => current_user)
    if @article.save
      respond_to do |format|
        format.json { render :json => {:id => @article.id} }
      end
    else
      respond_to do |format|
        format.json { render :text => @article.errors.full_messages, :status => :error }
      end
    end
  end

  def show
    @article = current_user.articles.find(params[:id])
    render :editor, :layout => false
  end

  def update
    @article = current_user.articles.find params[:id]
    if @article.update_attributes article_params
      respond_to do |format|
        format.json { render :json => {:id => @article.id} }
      end
    else
      respond_to do |format|
        format.json { render :text => @article.errors.full_messages, :status => :error }
      end
    end
  end

  private

  def find_book
    @book = current_user.books.find_by(:urlname => params[:book_id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :urlname)
  end
end
