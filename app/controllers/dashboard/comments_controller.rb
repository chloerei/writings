class Dashboard::CommentsController < Dashboard::BaseController
  before_filter :find_comment, :except => [:create]

  def create
    @discussion = @space.discussions.find_by :token => params[:discussion_id]
    @comment = @discussion.comments.create comment_params.merge(:space => @space, :user => current_user)
  end

  def edit
  end

  def update
    @comment.update_attributes comment_params
  end

  def destroy
    @comment.destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_comment
    @comment = @space.comments.find_by :token => params[:id]
  end
end
