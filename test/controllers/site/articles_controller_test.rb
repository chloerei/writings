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

  test "should redirect to subdomain if free" do
    @space.update_attribute :domain, 'custom.domain'

    @request.host = "#{@space.name}.#{APP_CONFIG["host"]}"
    get :index
    assert_response :success, @response.body

    @request.host = 'custom.domain'
    get :index
    assert_redirected_to "http://#{@space.name}.#{APP_CONFIG["host"]}/"
  end

  test "should redirect to domain if no free" do
    @space.update_attributes :domain => 'custom.domain', :plan => :base, :plan_expired_at => 1.day.from_now
    @request.host = 'custom.domain'
    get :index
    assert_response :success, @response.body

    @request.host = "#{@space.name}.#{APP_CONFIG["host"]}"
    get :index
    assert_redirected_to "http://#{@space.domain}/"
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

  test "should get feed" do
    get :feed, :format => :rss
    assert_response :success, @response.body
  end
end
