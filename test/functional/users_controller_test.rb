require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get signup page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create news" do
    post :create, :user => attributes_for(:user).slice(:name)
    assert_template :new

    assert_difference "User.count" do
      post :create, :user => attributes_for(:user)
    end
    assert_redirected_to root_url
  end

  test "should get edit page" do
    login_as create(:user)
    get :edit
    assert_response :success, @response.body
  end

  test "should update account" do
    password = '12345678'
    login_as create(:user, :password => password, :password_confirmation => password)
    put :update, :user => { :name => 'change', :current_password => password }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', current_user.reload.name
  end
end
