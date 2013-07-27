require 'test_helper'

class BillingsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should get show page" do
    get :show
    assert_response :success, @response.body
  end
end
