class Dashboard::TopicsController < Dashboard::BaseController
  before_filter :find_topic, :except => [:new, :create]

  def show
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.create topic_params.merge(:workspace => @space, :user => current_user)
  end

  def edit
  end

  def update
    @topic.update_attributes topic_params
  end

  def archive
    @topic.update_attribute :archived, true
    render :update
  end

  def open
    @topic.update_attribute :archived, false
    render :update
  end

  def destroy
    @topic.destroy
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :body)
  end

  def find_topic
    @topic = @space.topics.find_by :token => params[:id]
  end
end
