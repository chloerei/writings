require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "read_blog" do
    login_as create(:user)
    assert_nil current_user.read_blog_at
    post :read_blog
    assert_not_nil current_user.read_blog_at
  end
end
