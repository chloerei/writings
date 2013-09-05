require 'test_helper'

class Dashboard::ArticlesControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    @article = create(:article, :space => @space)
    login_as @space.user

    request.env["HTTP_REFERER"] = dashboard_root_url(:space_id => @space)
  end

  test "should get new page" do
    get :new, :space_id => @space
    assert_response :success, @response.body
  end

  test "should get index" do
    get :index, :space_id => @space
    assert_response :success, @response.body

    get :index, :space_id => @space, :status => 'publish'
    assert_response :success, @response.body

    get :index, :space_id => @space, :status => 'publish'
    assert_response :success, @response.body

    get :index, :space_id => @space, :format => :js
    assert_response :success, @response.body
  end

  test "should create article" do
    assert_difference "@space.articles.count" do
      post :create, :space_id => @space, :format => :json, :article => attributes_for(:article)
      assert_response :success, @response.body
    end
    assert_equal current_user, assigns(:article).user

    # strong parameters
    other_space = create(:space)
    assert_no_difference "other_space.articles.count" do
      assert_difference "@space.articles.count" do
        post :create, :space_id => @space, :format => :json, :article => attributes_for(:article).merge(:space_id => other_space.id)
        assert_response :success, @response.body
      end
    end
  end

  test "should edit article" do
    get :edit, :space_id => @space, :id => @article
    assert_response :success, @response.body
  end

  test "should update article" do
    put :update, :space_id => @space, :id => @article, :article => { :title => 'change', :save_count => @article.save_count + 1 }, :format => :json
    assert_response :success, @response.body
    assert_equal 'change', @article.reload.title
  end

  test "should empty trash" do
    2.times { create :article, :space => @space, :status => 'trash' }
    assert_difference "@space.articles.count", -2 do
      delete :empty_trash, :space_id => @space, :format => :js
    end
  end

  test "should not access when no member or no plan" do
    member = create :user
    login_as member

    assert_raise(Dashboard::BaseController::AccessDenied) do
      get :index, :space_id => @space
    end

    @space.members << member
    assert_raise(Dashboard::BaseController::AccessDenied) do
      get :index, :space_id => @space
    end

    @space.update_attributes :plan => :base, :plan_expired_at => 1.day.from_now
    assert_nothing_raised do
      get :index, :space_id => @space
    end
  end

  test "should lock article when someone editing" do
    member = create :user
    @space.members << member
    @space.update_attributes :plan => :base, :plan_expired_at => 1.day.from_now
    article = create :article, :space => @space

    put :update, :space_id => @space, :id => article, :article => { :title => 'change', :save_count => article.reload.save_count + 1 }, :format => :json
    assert_response :success, @response.body
    assert article.locked?
    assert article.locked_by?(current_user)

    login_as member
    put :update, :space_id => @space, :id => article, :article => { :title => 'change', :save_count => article.reload.save_count + 1 }
    assert_response 400, @response.body
  end

  test "restore" do
    article = create :article, :space => @space, :status => 'trash'

    assert_difference "@space.articles.draft.count" do
      put :restore, :space_id => @space, :id => article
    end
  end

  test "batch trash" do
    ids = 2.times.map { create(:article, :space => @space).token }

    assert_difference "@space.articles.untrash.count", -2 do
      put :batch_trash, :space_id => @space, :ids => ids, :format => :js
    end
  end

  test "batch restroe" do
    ids = 2.times.map { create(:article, :space => @space, :status => 'trash').token }

    assert_difference "@space.articles.untrash.count", 2 do
      put :batch_restore, :space_id => @space, :ids => ids, :format => :js
    end
  end

  test "batch publish" do
    ids = 2.times.map { create(:article, :space => @space, :status => 'draft').token }

    assert_difference "@space.articles.publish.count", 2 do
      put :batch_publish, :space_id => @space, :ids => ids, :format => :js
    end
  end

  test "batch draft" do
    ids = 2.times.map { create(:article, :space => @space, :status => 'publish').token }

    assert_difference "@space.articles.draft.count", 2 do
      put :batch_draft, :space_id => @space, :ids => ids, :format => :js
    end
  end

  test "batch destroy" do
    ids = 2.times.map { create(:article, :space => @space, :status => 'trash').token }

    assert_difference "@space.articles.count", -2 do
      put :batch_destroy, :space_id => @space, :ids => ids, :format => :js
    end

    ids = 2.times.map { create(:article, :space => @space, :status => 'draft').token }

    assert_no_difference "@space.articles.count" do
      put :batch_destroy, :space_id => @space, :ids => ids, :format => :js
    end
  end
end
