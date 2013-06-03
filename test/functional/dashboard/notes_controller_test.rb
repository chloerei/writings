require 'test_helper'

class Dashboard::NotesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    @article = create :article, :space => @workspace
    @note = create :note, :article => @article, :user => @user, :workspace => @workspace
    login_as @user
  end

  test "should create note" do
    assert_difference ["@workspace.discussions.count", "@article.notes.count"] do
      post :create, :space_id => @workspace, :article_id => @article.to_param, :note => { :body => 'text', :element_id => '1111' }, :format => :js
    end
  end

  test "should archive note" do
    put :archive, :space_id => @workspace, :id => @note, :format => :js
    assert @note.reload.archived?
  end

  test "should destroy note" do
    assert_difference "@article.notes.count", -1 do
      delete :destroy, :space_id => @workspace, :id => @note, :format => :js
    end
  end
end
