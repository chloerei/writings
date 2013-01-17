require 'test_helper'

class Site::ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @article = create :article, :user => @user
    @request.host = "#{@user.name}.local.test"
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body
  end

  test "should get show" do
    get :show, :id => @article
    assert_response :success, @response.body
  end

  test "should get feed" do
    get :feed, :format => :rss
    assert_response :success, @response.body
  end
end
