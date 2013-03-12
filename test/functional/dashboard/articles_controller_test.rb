require 'test_helper'

class Dashboard::ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    @category = create(:category, :user => @user)
    @article = create(:article, :user => @user, :category => @category)
    login_as @user
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body

    get :index, :status => 'publish'
    assert_response :success, @response.body

    get :index, :format => :js
    assert_response :success, @response.body
  end

  test "should get not_collected" do
    get :not_collected
    assert_response :success, @response.body

    create(:article, :status => 'publish', :user => @user)
    get :not_collected, :status => :publish
    assert_response :success, @response.body
  end

  test "should get category articles" do
    get :category, :category_id => @category
    assert_response :success, @response.body

    get :category, :category_id => @category, :format => :js
    assert_response :success, @response.body
  end

  test "should get not_collected articles" do
    get :not_collected
    assert_response :success, @response.body

    get :not_collected, :format => :js
    assert_response :success, @response.body
  end

  test "should create article" do
    assert_difference "@user.articles.count" do
      post :create, :format => :json, :article => attributes_for(:article)
      assert_response :success, @response.body
    end

    assert_difference ["@user.articles.count", "@category.articles.count"] do
      post :create, :format => :json, :article => attributes_for(:article).merge(:category_id => @category.urlname)
      assert_response :success, @response.body
    end

    # strong parameters
    other = create(:user)
    assert_no_difference "other.articles.count" do
      assert_difference "@user.articles.count" do
        post :create, :format => :json, :article => attributes_for(:article).merge(:user_id => other.id)
        assert_response :success, @response.body
      end
    end
  end

  test "should edit article" do
    get :edit, :id => @article
    assert_response :success, @response.body
  end

  test "should update article" do
    put :update, :id => @article, :article => { :title => 'change', :save_count => @article.save_count + 1 }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @article.reload.title
  end

  test "should should bulk update article" do
    article1 = create :article, :user => @user
    article2 = create :article, :user => @user
    create :article, :user => @user
    assert_difference "@category.articles.count", 2 do
      post :bulk, :ids => [article1.token, article2.token], :type => 'move', :category_id => @category.urlname, :format => :json
    end

    assert_difference "@category.articles.publish.count", 2 do
      post :bulk, :ids => [article1.token, article2.token], :type => 'publish', :category_id => @category.urlname, :format => :json
    end

    assert_difference "@category.articles.publish.count", -2 do
      post :bulk, :ids => [article1.token, article2.token], :type => 'draft', :category_id => @category.urlname, :format => :json
    end

    assert_difference "@category.articles.trash.count", 2 do
      post :bulk, :ids => [article1.token, article2.token], :type => 'trash', :category_id => @category.urlname, :format => :json
    end

    assert_difference "@category.articles.count", -2 do
      post :bulk, :ids => [article1.token, article2.token], :type => 'delete', :category_id => @category.urlname, :format => :json
    end
  end

  test "should empty trash" do
    2.times { create :article, :user => @user, :status => 'trash' }
    assert_difference "@user.articles.count", -2 do
      delete :empty_trash, :format => :json
    end

    2.times { create :article, :user => @user, :status => 'trash', :category => @category }
    create :article, :user => @user, :status => 'trash'
    assert_difference "@user.articles.count", -2 do
      delete :empty_trash, :format => :json, :category_id => @category.urlname
    end

    assert_difference "@user.articles.count", -1 do
      delete :empty_trash, :format => :json, :not_collected => true
    end
  end
end
