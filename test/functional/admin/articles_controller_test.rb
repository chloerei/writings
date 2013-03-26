require 'test_helper'

class Admin::ArticlesControllerTest < ActionController::TestCase
  def setup
    login_as create(:user, :email => APP_CONFIG['admin_emails'].first)
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body
  end
end
