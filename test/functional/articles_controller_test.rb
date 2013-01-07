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

    get :index, :format => :js
    assert_response :success, @response.body
  end

  test "should get book articles" do
    get :book, :book_id => @book
    assert_response :success, @response.body

    get :book, :book_id => @book, :format => :js
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

  test "should should bulk update article" do
    article1 = create :article, :user => @user
    article2 = create :article, :user => @user
    create :article, :user => @user
    assert_difference "@book.articles.count", 2 do
      post :bulk, :ids => [article1.id, article2.id], :type => 'move', :book_id => @book.urlname, :format => :json
    end

    assert_difference "@book.articles.publish.count", 2 do
      post :bulk, :ids => [article1.id, article2.id], :type => 'publish', :book_id => @book.urlname, :format => :json
    end

    assert_difference "@book.articles.publish.count", -2 do
      post :bulk, :ids => [article1.id, article2.id], :type => 'draft', :book_id => @book.urlname, :format => :json
    end

    assert_difference "@book.articles.trash.count", 2 do
      post :bulk, :ids => [article1.id, article2.id], :type => 'trash', :book_id => @book.urlname, :format => :json
    end

    assert_difference "@book.articles.count", -2 do
      post :bulk, :ids => [article1.id, article2.id], :type => 'delete', :book_id => @book.urlname, :format => :json
    end
  end

  test "should empty trash" do
    2.times { create :article, :user => @user, :status => 'trash' }
    assert_difference "@user.articles.count", -2 do
      delete :empty_trash, :format => :json
    end

    2.times { create :article, :user => @user, :status => 'trash', :book => @book }
    create :article, :user => @user, :status => 'trash'
    assert_difference "@user.articles.count", -2 do
      delete :empty_trash, :format => :json, :book_id => @book.urlname
    end

    assert_difference "@user.articles.count", -1 do
      delete :empty_trash, :format => :json, :not_collected => true
    end
  end
end
