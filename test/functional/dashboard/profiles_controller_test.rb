require 'test_helper'

class Dashboard::ProfilesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should show profile page" do
    get :show, :space_id => @user
    assert_response :success, @response.body
  end

  test "should update profile" do
    put :update, :space_id => @user, :profile => { :name => 'change' }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @user.reload.profile.name
  end
end
