require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  def setup
    @password = '12345678'
    @user = create(:user, :password => @password, :password_confirmation => @password)
    login_as @user
  end

  test "should get show page" do
    get :show
    assert_response :success, @response.body
  end

  test "should update account" do
    put :update, :user => { :name => 'change', :current_password => @password }, :format => :js
    assert_response :success, @response.body
    assert_equal 'change', @user.reload.name

    # remmove domain
    @user.update_attribute :domain, 'old'
    put :update, :user => { :domain => '', :current_password => @password }, :format => :js
    assert_response :success, @response.body
    assert_equal '', @user.reload.domain
  end

  test "should not update if current_password error" do
    put :update, :user => { :name => 'change' }, :format => :js
    assert_not_equal 'change', @user.reload.name

    put :update, :user => { :name => 'change', :password => 'wrong' }, :format => :js
    assert_not_equal 'change', @user.reload.name
  end
end
