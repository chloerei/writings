require 'test_helper'

class Dashboard::MembersControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    login_as @space.user
  end

  test "should get workspace members" do
    get :index, :space_id => @space
    assert_response :success, @response.body
  end

  test "should destroy member" do
    member = create :user
    @space.members << member
    assert_difference "@space.reload.members.count", -1 do
      delete :destroy, :space_id => @space, :id => member, :format => :js
    end
  end
end
