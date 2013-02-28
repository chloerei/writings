require 'test_helper'

class Site::CategoriesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @category = create :category, :user => @user
    @article = create :article, :user => @user, :category => @category, :status => 'publish'
    @request.host = "#{@user.name}.#{APP_CONFIG["host"]}"
  end

  test "should get show" do
    get :show, :id => @category.urlname
    assert_response :success, @response.body
  end

  test "should get feed" do
    get :feed, :id => @category.urlname, :format => :rss
    assert_response :success, @response.body
  end
end
