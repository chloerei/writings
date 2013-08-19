class Site::AuthorsController < Site::BaseController
  def index
    @authors = @space.members
  end

  def show
    @author = @space.members.find_by :name => params[:id]
    @articles = @space.articles.publish.desc(:published_at).where(:user_id => @author.id).page(params[:page]).per(5)
  end
end
