require 'test_helper'

class Dashboard::TopicsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    login_as @user
  end

  test "show get new page" do
    get :new, :space_id => @workspace
    assert_response :success, @response.body
  end
end
