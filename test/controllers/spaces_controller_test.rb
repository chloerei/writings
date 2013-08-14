require 'test_helper'

class SpacesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create new workspace" do
    assert_difference "@user.spaces.count" do
      post :create, :space => attributes_for(:space), :format => :js
    end
  end
end
