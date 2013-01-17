class Site::BooksController < Site::BaseController
  def index
    @books = @user.books.desc(:updated_at)
  end

  def show
    @book = @user.books.find_by :urlname => params[:id]
    @articles = @book.articles.desc(:created_at).page(params[:page])
  end
end
