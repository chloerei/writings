require 'test_helper'

class Dashboard::BillingsControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    login_as @space.user
  end

  test "should get show page" do
    get :show, :space_id => @space
    assert_response :success, @response.body
  end
end
