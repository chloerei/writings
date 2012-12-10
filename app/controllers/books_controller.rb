class BooksController < ApplicationController
  before_filter :require_logined

  def show
    @book = current_user.books.find_by(:urlname => params[:id])
  end

  def new
    @book = current_user.books.new
  end

  def create
    @book = current_user.books.new book_params

    if @book.save
      redirect_to @book
    else
      render :new
    end
  end

  def edit
    @book = current_user.books.find_by(:urlname => params[:id])
  end

  def update
    @book = current_user.books.find_by(:urlname => params[:id])

    if @book.update_attributes book_params
      redirect_to edit_book_url(@book)
    else
      render :new
    end
  end

  private

  def book_params
    params.require(:book).permit(:name, :urlname)
  end
end
