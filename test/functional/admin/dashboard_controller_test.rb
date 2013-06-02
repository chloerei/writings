require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase
  def setup
    APP_CONFIG['admin_emails'] = %w(admin@writings.io)
    @admin = create :user, :email => 'admin@writings.io'
    @user = create :user
  end

  test "access check" do
    get :show
    assert_response 302, @response.body

    login_as @user
    get :show
    assert_response 404, @response.body

    login_as @admin
    get :show
    assert_response :success, @response.body
  end
end
