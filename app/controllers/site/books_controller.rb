class Site::BooksController < Site::BaseController
  def index
    @books = @user.books.desc(:updated_at)
  end

  def show
    @book = @user.books.find_by :urlname => params[:id]
    @articles = @book.articles.desc(:created_at).page(params[:page])
  end

  def feed
    @book = @user.books.find_by :urlname => params[:id]
    @articles = @book.articles.desc(:created_at).limit(20)
    @feed_title = "#{@book.name} - #{@user.profile.name.present? ? @user.profile.name : @user.name}"
    @feed_link = site_book_url(@book)

    respond_to do |format|
      format.rss { render 'site/articles/feed' }
    end
  end
end
