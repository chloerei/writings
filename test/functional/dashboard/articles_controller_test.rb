require 'test_helper'

class Dashboard::ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    @category = create(:category, :space => @user)
    @article = create(:article, :space => @user, :category => @category)
    login_as @user

    request.env["HTTP_REFERER"] = dashboard_root_url(:space_id => @user)
  end

  test "should get new page" do
    get :new, :space_id => @user
    assert_response :success, @response.body
  end

  test "should get index" do
    get :index, :space_id => @user
    assert_response :success, @response.body

    get :index, :space_id => @user, :status => 'publish'
    assert_response :success, @response.body

    get :index, :space_id => @user, :category_id => @category, :status => 'publish'
    assert_response :success, @response.body

    get :index, :space_id => @user, :format => :js
    assert_response :success, @response.body
  end

  test "should create article" do
    assert_difference "@user.articles.count" do
      post :create, :space_id => @user, :format => :json, :article => attributes_for(:article)
      assert_response :success, @response.body
    end

    assert_difference ["@user.articles.count", "@category.articles.count"] do
      post :create, :space_id => @user, :format => :json, :article => attributes_for(:article).merge(:category_id => @category.token)
      assert_response :success, @response.body
    end

    # strong parameters
    other = create(:user)
    assert_no_difference "other.articles.count" do
      assert_difference "@user.articles.count" do
        post :create, :space_id => @user, :format => :json, :article => attributes_for(:article).merge(:space_id => other.id)
        assert_response :success, @response.body
      end
    end
  end

  test "should edit article" do
    get :edit, :space_id => @user, :id => @article
    assert_response :success, @response.body
  end

  test "should update article" do
    put :update, :space_id => @user, :id => @article, :article => { :title => 'change', :save_count => @article.save_count + 1 }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @article.reload.title
  end

  test "should empty trash" do
    2.times { create :article, :space => @user, :status => 'trash' }
    assert_difference "@user.articles.count", -2 do
      delete :empty_trash, :space_id => @user, :format => :js
    end
  end

  test "should lock article when someone editing" do
    workspace = create :workspace, :creator => @user
    member = create :user
    workspace.members << member
    article = create :article, :space => workspace

    put :update, :space_id => workspace, :id => article, :article => { :title => 'change', :save_count => article.reload.save_count + 1 }, :format => :json
    assert_response :success, @response.body
    assert article.locked?
    assert article.locked_by?(@user)

    login_as member
    put :update, :space_id => workspace, :id => article, :article => { :title => 'change', :save_count => article.reload.save_count + 1 }
    assert_response 400, @response.body
  end

  test "batch category" do
    ids = 2.times.map { create(:article, :space => @user).token }
    assert_difference "@category.articles.count", 2 do
      put :batch_category, :space_id => @user, :ids => ids, :category_id => @category.token, :format => :js
    end
  end
end
