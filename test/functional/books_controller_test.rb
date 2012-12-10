require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
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

    post :create, attributes_for(:book).slice(:name)
    assert_template :new
  end
end
