require 'test_helper'

class Dashboard::CategoriesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @category = create :category, :space => @user
    login_as @user
  end

  test "should create category" do
    assert_difference "@user.categories.count" do
      post :create, :category => attributes_for(:category), :format => :json
      assert_response :success, @response.body
    end
  end

  test "should get edit page" do
    get :edit, :id => @category
    assert_response :success, @response.body
  end

  test "should update category" do
    post :update, :id => @category, :category => { :name => 'change' }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @category.reload.name
  end

  test "should destroy category" do
    assert_difference "@user.categories.count", -1 do
      delete :destroy, :id => @category
      assert_redirected_to root_url
    end
  end
end
