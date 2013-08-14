require 'test_helper'

class Dashboard::SettingsControllerTest < ActionController::TestCase
  def setup
    @space = create(:space)
    login_as @space.user
  end

  test "should get show page" do
    get :show, :space_id => @space
    assert_response :success, @response.body
  end

  test "should update" do
    put :update, :space_id => @space, :space => { :domain => 'change' }, :format => :js
    assert_response :success, @response.body
    assert_equal 'change', @space.reload.domain
  end
end
