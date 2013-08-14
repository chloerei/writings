require 'test_helper'

class Site::CategoriesControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    @category = create :category, :space => @space
    @article = create :article, :space => @space, :category => @category, :status => 'publish'
    @request.host = "#{@space.name}.#{APP_CONFIG["host"]}"
  end

  test "should get show" do
    get :show, :id => @category
    assert_response :success, @response.body
  end

  test "should get feed" do
    get :feed, :id => @category, :format => :rss
    assert_response :success, @response.body
  end
end
