require 'test_helper'

class MainControllerTest < ActionController::TestCase
  test "show guest index when no login" do
    get :index
    assert_template :guest_index

    login_as create(:user)
    get :index
    assert_template :index
  end
end
