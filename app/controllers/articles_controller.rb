class ArticlesController < ApplicationController
  before_filter :require_logined

  def index
    if logined?
      @articles = current_user.articles.desc(:created_at)

      case params[:status]
      when 'publish'
        @articles = @articles.publish
      when 'draft'
        @articles = @articles.draft
      end

      if params[:book].present?
        @book = current_user.books.where(:urlname => params[:book].to_s).first
        @articles = @articles.where(:book_id => @book.try(:id))
      elsif params[:not_collected]
        @articles = @articles.where(:book_id => nil)
      end

    else
      render :guest_index
    end
  end
  def create
    @article = current_user.articles.create :book => current_user.books.where(:urlname => params[:book_id]).first
    redirect_to edit_article_url(@article)
  end

  def edit
    @article = current_user.articles.find(params[:id])
    render :layout => false
  end

  def update
    @article = current_user.articles.find params[:id]
    if @article.update_attributes article_params
      respond_to do |format|
        format.json { render :json => {:id => @article.id, :urlname => @article.urlname} }
      end
    else
      respond_to do |format|
        format.json { render :text => @article.errors.full_messages, :status => :error }
      end
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body, :urlname, :publish)
  end
end
