require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @book = create :book, :user => @user
    login_as @user
  end

  test "should show book" do
    get :show, :id => @book
    assert_response :success, @response.body
  end

  test "should show draft list" do
    get :draft, :id => @book
    assert_response :success, @response.body
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create book" do
    assert_difference "@user.books.count" do
      post :create, :book => attributes_for(:book)
      assert_redirected_to @user.books.last
    end

    post :create, :book => attributes_for(:book).slice(:name)
    assert_template :new
  end

  test "should get edit page" do
    get :edit, :id => @book
    assert_response :success, @response.body
  end

  test "should update book" do
    post :update, :id => @book, :book => { :name => 'change' }
    assert_redirected_to edit_book_url(@book)
    assert_equal 'change', @book.reload.name
  end

  test "should destroy book" do
    assert_difference "@user.books.count", -1 do
      delete :destroy, :id => @book
      assert_redirected_to root_url
    end
  end
end
