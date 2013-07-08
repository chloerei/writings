require 'test_helper'

class Dashboard::MembersControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    login_as @user
  end

  test "should get workspace members" do
    get :index, :space_id => @user
    assert_redirected_to dashboard_root_path(:space_id => @user)

    get :index, :space_id => @workspace
    assert_response :success, @response.body
  end

  test "should destroy member" do
    member = create :user
    @workspace.members << member
    assert_difference "@workspace.reload.members.count", -1 do
      delete :destroy, :space_id => @workspace, :id => member, :format => :js
    end
  end
end
