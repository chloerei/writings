require 'test_helper'

class Dashboard::CategoriesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @space = create :space, :user => @user
    @category = create :category, :space => @space
    login_as @user
  end

  test "should create category" do
    assert_difference "@space.categories.count" do
      post :create, :space_id => @space, :category => attributes_for(:category), :format => :js
      assert_response :success, @response.body
    end
  end

  test "should get edit page" do
    get :edit, :space_id => @space, :id => @category, :format => :js
    assert_response :success, @response.body
  end

  test "should update category" do
    post :update, :space_id => @space, :id => @category, :category => { :name => 'change' }, :format => :js
    assert_response :success, @response.body
    assert_equal 'change', @category.reload.name
  end

  test "should destroy category" do
    assert_difference "@space.categories.count", -1 do
      delete :destroy, :space_id => @space, :id => @category, :format => :js
    end
  end
end
