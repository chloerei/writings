require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    @book = create(:book, :user => @user)
    @article = create(:article, :book => @book)
    login_as @user
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body

    get :index, :status => 'publish'
    assert_response :success, @response.body

    get :index, :book => @book.urlname
    assert_response :success, @response.body
  end

  test "should create article" do
    assert_difference "@user.articles.count" do
      post :create
      assert_redirected_to edit_article_url(current_user.articles.last)
    end

    assert_difference ["@user.articles.count", "@book.articles.count"] do
      post :create, :book_id => @book
      assert_redirected_to edit_article_url(current_user.articles.last)
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
