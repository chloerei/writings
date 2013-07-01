require 'test_helper'

class Dashboard::CommentsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    @discussion = create :topic, :space => @workspace, :user => @user
    @comment = create :comment, :discussion => @discussion, :space => @workspace
    login_as @user
  end

  test "should create comment" do
    assert_difference "@discussion.comments.count" do
      post :create, :space_id => @workspace, :discussion_id => @discussion.to_param, :comment => { :body => 'text' }, :format => :js
    end
  end

  test "should edit comment" do
    get :edit, :space_id => @workspace, :id => @comment
    assert_response :success, @response.body
  end

  test "should update comment" do
    put :update, :space_id => @workspace, :id => @comment, :comment => { :body => 'change' }, :format => :js
    assert_equal 'change', @comment.reload.body
  end

  test "should destroy comment" do
    assert_difference "@workspace.comments.count", -1 do
      delete :destroy, :space_id => @workspace, :id => @comment, :format => :js
    end
  end
end
