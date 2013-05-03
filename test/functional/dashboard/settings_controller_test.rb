require 'test_helper'

class Dashboard::SettingsControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    login_as @user
  end

  test "should get show page" do
    get :show, :space_id => @user
    assert_response :success, @response.body
  end

  test "should update" do
    put :update, :space_id => @user, :user => { :domain => 'change' }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @user.reload.domain
  end
end
