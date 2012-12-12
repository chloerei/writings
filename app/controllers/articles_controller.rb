class ArticlesController < ApplicationController
  before_filter :require_logined
  before_filter :find_book

  def new
    @article = @book.articles.new
    render :editor, :layout => false
  end

  private

  def find_book
    @book = current_user.books.find_by(:urlname => params[:book_id])
  end
end
