class Site::BooksController < Site::BaseController
  def index
    @books = @user.books.desc(:updated_at)
  end
end
