require 'test_helper'

class WorkspacesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create new workspace" do
    assert_difference "@user.own_workspaces.count" do
      post :create, :workspace => attributes_for(:workspace)
    end
  end
end
