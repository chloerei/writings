require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @book = create :book, :user => @user
    login_as @user
  end

  test "should create book" do
    assert_difference "@user.books.count" do
      post :create, :book => attributes_for(:book), :format => :json
      assert_response :success, @response.body
    end
  end

  test "should get edit page" do
    get :edit, :id => @book
    assert_response :success, @response.body
  end

  test "should update book" do
    post :update, :id => @book, :book => { :name => 'change' }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @book.reload.name
  end

  test "should destroy book" do
    assert_difference "@user.books.count", -1 do
      delete :destroy, :id => @book
      assert_redirected_to root_url
    end
  end
end
