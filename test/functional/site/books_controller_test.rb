require 'test_helper'

class Site::BooksControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @book = create :book, :user => @user
    @article = create :article, :user => @user, :book => @book, :status => 'publish'
    @request.host = "#{@user.name}.#{APP_CONFIG["host"]}"
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body
  end

  test "should get show" do
    get :show, :id => @book.urlname
    assert_response :success, @response.body
  end

  test "should get feed" do
    get :feed, :id => @book.urlname, :format => :rss
    assert_response :success, @response.body
  end
end
