require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should generate password_reset_token" do
    user = create :user
    user.generate_password_reset_token
    assert_not_nil user.password_reset_token
    assert_not_nil user.password_reset_token_created_at

    user.unset_password_reset_token
    assert_nil user.password_reset_token
    assert_nil user.password_reset_token_created_at
  end
end
