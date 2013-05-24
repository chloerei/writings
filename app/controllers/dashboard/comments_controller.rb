class Dashboard::CommentsController < Dashboard::BaseController
  def create
    @discussion = @space.discussions.find_by :token => params[:discussion_id]
    @comment = @discussion.comments.create comment_params.merge(:user => current_user)
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
