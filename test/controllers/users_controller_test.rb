require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get signup page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create user" do
    assert_no_difference "User.count" do
      post :create, :user => attributes_for(:user).slice(:email), :format => :js
    end

    assert_difference "User.count" do
      post :create, :user => attributes_for(:user), :format => :js
    end
  end
end
