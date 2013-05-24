require 'test_helper'

class Dashboard::TopicsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    @topic = create :topic, :workspace => @workspace
    login_as @user
  end

  test "show get new page" do
    get :new, :space_id => @workspace
    assert_response :success, @response.body
  end

  test "should edit topic" do
    get :edit, :space_id => @workspace, :id => @topic
    assert_response :success, @response.body
  end

  test "should update topic" do
    put :update, :space_id => @workspace, :id => @topic, :topic => { :body => 'change' }, :format => :js
    assert_equal 'change', @topic.reload.body
  end

  test "should archive topic" do
    put :archive, :space_id => @workspace, :id => @topic, :format => :js
    assert_equal true, @topic.reload.archived?
  end

  test "should open topic" do
    put :open, :space_id => @workspace, :id => @topic, :format => :js
    assert_equal false, @topic.reload.archived?
  end

  test "should destroy topic" do
    assert_difference "@workspace.topics.count", -1 do
      delete :destroy, :space_id => @workspace, :id => @topic, :format => :js
    end
  end
end
