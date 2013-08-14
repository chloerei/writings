require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  def setup
    @user = create :user, :password => 'password'
  end

  test "should get login page" do
    get :new
    assert_response :success, @response.body
  end

  test "should login with name and right password" do
    post :create, :login => @user.name, :password => 'password', :format => :js
    assert_equal @user, current_user
  end

  test "should login with email and right password" do
    post :create, :login => @user.email, :password => 'password', :format => :js
    assert_equal @user, current_user
  end

  test "should remember me" do
    post :create, :login => @user.email, :password => 'password', :remember_me => 'yes', :format => :js
    assert_equal @user, current_user
    assert_equal @user.remember_token, cookies[:remember_token]
  end

  test "should no login with name or email with wrong password" do
    post :create, :login => @user.name, :password => 'wrong password', :format => :js
    assert_nil current_user

    post :create, :login => @user.email, :password => 'wrong password', :format => :js
    assert_nil current_user
  end

  test "should login from session" do
    session[:user_id] = @user.id
    assert_equal @user, current_user
  end

  test "should logout" do
    login_as @user
    delete :destroy, :format => :js
    assert !logined?
  end
end
