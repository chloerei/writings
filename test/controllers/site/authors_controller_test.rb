require 'test_helper'

class Site::AuthorsControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    @request.host = "#{@space.name}.#{APP_CONFIG["host"]}"
  end

  test "get authors index" do
    get :index
    assert_response :success, @response.body
  end

  test "get author page" do
    get :show, :id => @space.user
    assert_response :success, @response.body
  end
end
