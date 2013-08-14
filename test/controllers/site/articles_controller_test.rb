require 'test_helper'

class Site::ArticlesControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    @article = create :article, :space => @space, :status => 'publish'
    @request.host = "#{@space.name}.#{APP_CONFIG["host"]}"
  end

  test "should get index" do
    get :index
    assert_equal @space, assigns(:space)
    assert_response :success, @response.body
  end

  test "should get index when setting domain" do
    @space.update_attribute :domain, 'custom.domain'

    get :index
    assert_redirected_to "http://#{@space.domain}/"

    @request.host = 'custom.domain'
    get :index
    assert_equal @space, assigns(:space)
    assert_response :success, @response.body
  end

  test "should get show" do
    get :show, :id => @article
    assert_response :success, @response.body
  end

  test "should redirect when urlname wrong" do
    @article.update_attribute :urlname, 'urlname'
    get :show, :id => @article
    assert_redirected_to site_article_url(@article, :urlname => @article.urlname)
  end

  test "should redirect old_url" do
    @article.update_attribute :old_url, 'old-url'
    get :show, :id => 'old', :urlname => 'url'
    assert_redirected_to site_article_url(@article, :urlname => @article.urlname)

    @article.update_attribute :old_url, 'old'
    get :show, :id => 'old'
    assert_redirected_to site_article_url(@article, :urlname => @article.urlname)
  end

  test "should get feed" do
    get :feed, :format => :rss
    assert_response :success, @response.body
  end
end
