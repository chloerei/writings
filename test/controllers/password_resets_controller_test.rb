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
    assert_redirected_to dashboard_root_path(current_user)
  end

  test "should create reset" do
    assert_difference "Sidekiq::Extensions::DelayedMailer.jobs.size" do
      post :create, :email => @user.email, :format => :js
      assert_not_nil assigns(:user)
    end
  end
end
