class BooksController < ApplicationController
  before_filter :require_logined

  def new
    @book = current_user.books.new
  end

  def create
    @book = current_user.books.new params[:book]

    if @book.save
      redirect_to @book
    else
      render :new
    end
  end
end
