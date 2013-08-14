require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
  end
  test "should get new page" do
    get :new
    assert_response :success, @response.body

    login_as @user
    get :new
    assert_redirected_to root_path
  end

  test "should create reset" do
    assert_difference "Sidekiq::Extensions::DelayedMailer.jobs.size" do
      post :create, :email => @user.email, :format => :js
      assert_not_nil assigns(:user)
    end
  end

  test "should get edit page" do
    @user.generate_password_reset_token
    get :edit, :id => @user.password_reset_token
    assert_response :success, @response.body

    get :edit, :id => 'fake_id'
    assert_redirected_to new_password_reset_path
  end

  test "should update password" do
    @user.generate_password_reset_token
    patch :update, :id => @user.password_reset_token, :user => { :password => '12345678', :password_confirmation => '12345678' }, :format => :js
    assert_not_nil @user.reload.authenticate '12345678'
    assert_nil @user.password_reset_token
    assert_nil @user.password_reset_token_created_at
  end
end
