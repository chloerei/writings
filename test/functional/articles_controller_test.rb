require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    @book = create(:book, :user => @user)
    login_as @user
  end

  test "should get new page" do
    get :new, :book_id => @book
    assert_response :success, @response.body
  end
end
