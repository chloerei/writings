require 'test_helper'

class Site::ArchivesControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    @article = create :article, :space => @space, :status => 'publish'
    @article = create :article, :space => @space, :status => 'publish', :published_at => 1.month.ago
    @request.host = "#{@space.name}.#{APP_CONFIG["host"]}"
  end

  test "should get index" do
    get :index
    assert_response :success, @response.body
  end
end
