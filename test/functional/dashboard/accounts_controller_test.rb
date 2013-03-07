require 'test_helper'

class Dashboard::AccountsControllerTest < ActionController::TestCase
  test "should get show page" do
    login_as create(:user)
    get :show
    assert_response :success, @response.body
  end

  test "should update account" do
    password = '12345678'
    login_as create(:user, :password => password, :password_confirmation => password)
    put :update, :user => { :name => 'change', :current_password => password }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', current_user.reload.name

    # remmove domain
    current_user.update_attribute :domain, 'old'
    put :update, :user => { :domain => '', :current_password => password }, :format => :json
    assert_response :success, @response.body
    assert_equal '', current_user.reload.domain
  end
end
