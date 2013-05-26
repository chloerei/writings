require 'test_helper'

class Dashboard::NotesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    @article = create :article, :space => @workspace
    login_as @user
  end

  test "should create article" do
    assert_difference ["@workspace.discussions.count", "@article.notes.count"] do
      post :create, :space_id => @workspace, :article_id => @article.to_param, :note => { :body => 'text', :element_id => '1111' }, :format => :js
    end
  end
end
