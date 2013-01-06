class BooksController < ApplicationController
  before_filter :require_logined
  before_filter :find_book, :only => [:edit, :update, :destroy]

  def create
    @book = current_user.books.new book_params

    if @book.save
      respond_to do |format|
        format.json { render :json => @book.as_json(:only => [:urlname, :name]) }
      end
    else
      respond_to do |format|
        format.json { render :text => @book.errors.full_messages, :status => :error }
      end
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
