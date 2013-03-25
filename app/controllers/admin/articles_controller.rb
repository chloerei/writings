class Admin::ArticlesController < Admin::BaseController
  def index
    params[:tab] ||= 'publish'

    case params[:tab]
    when 'publish'
      @articles = Article.publish.desc(:published_at).includes(:user).page(params[:page]).per(25)
    when 'all'
      @articles = Article.desc(:updated_at).includes(:user).page(params[:page]).per(25)
    end
  end
end
