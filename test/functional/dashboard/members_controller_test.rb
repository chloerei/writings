require 'test_helper'

class Dashboard::MembersControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :owner => @user
    login_as @user
  end

  test "should get workspace members" do
    get :index, :space_id => @user
    assert_redirected_to dashboard_root_path(:space_id => @user)

    get :index, :space_id => @workspace
    assert_response :success, @response.body
  end
end
