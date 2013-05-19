class Dashboard::TopicsController < Dashboard::BaseController
  def show
    @topic = @space.topics.find params[:id]
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.create topic_params.merge(:workspace => @space, :user => current_user)
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :body)
  end
end
