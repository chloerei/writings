require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  test "should get show page" do
    user = create(:user)
    login_as user
    get :show
    assert_response :success, @response.body
  end

  test "should update account" do
    password = '12345678'
    user = create(:user, :password => password, :password_confirmation => password)
    login_as user
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
