class Dashboard::BooksController < Dashboard::BaseController
  before_filter :find_book, :only => [:edit, :update, :destroy]

  def new
    @book = Book.new :user => current_user
  end

  def create
    @book = current_user.books.new book_params

    if @book.save
      respond_to do |format|
        format.json { render :json => @book.as_json(:only => [:urlname, :name]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => 'Validation Failed', :errors => @book.errors }, :status => 400 }
      end
    end
  end

  def edit
  end

  def update
    if @book.update_attributes book_params
      respond_to do |format|
        format.json { render :json => @book.as_json(:only => [:urlname, :name]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => 'Validation Failed', :errors => @book.errors }, :status => 400 }
      end
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
    params.require(:book).permit(:name, :urlname, :description)
  end
end
