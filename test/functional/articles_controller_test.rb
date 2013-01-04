require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    @book = create(:book, :user => @user)
    @article = create(:article, :user => @user, :book => @book)
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

    get :index, :book => @book.urlname
    assert_response :success, @response.body
  end

  test "should respond to js" do
    get :index, :format => :js
    assert_response :success, @response.body
  end

  test "should create article" do
    assert_difference "@user.articles.count" do
      post :create, :format => :json, :article => attributes_for(:article)
      assert_response :success, @response.body
    end

    assert_difference ["@user.articles.count", "@book.articles.count"] do
      post :create, :format => :json, :article => attributes_for(:article).merge(:book_id => @book.urlname)
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
    put :update, :id => @article, :article => { :title => 'change' }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @article.reload.title
  end
end
