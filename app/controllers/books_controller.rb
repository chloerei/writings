class BooksController < ApplicationController
  before_filter :require_logined
  before_filter :find_book, :only => [:show, :edit, :update, :destroy]

  def show
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
  end

  def update
    if @book.update_attributes book_params
      redirect_to edit_book_url(@book)
    else
      render :new
    end
  end

  def destroy
    @book.destroy
    redirect_to root_url
  end

  private

  def find_book
    @book = current_user.books.find_by(:urlname => params[:id])
  end

  def book_params
    params.require(:book).permit(:name, :urlname)
  end
end
