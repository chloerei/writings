require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get signup page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create news" do
    post :create
    assert_template :new

    assert_difference "User.count" do
      post :create, :user => attributes_for(:user)
    end
    assert_redirected_to root_url
  end
end
