require 'test_helper'

class Dashboard::DiscussionsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    @topic = create :topic, :workspace => @workspace
    login_as @user
  end

  test "get index" do
    get :index, :space_id => @workspace
    assert_response :success, @response.body
  end
end
