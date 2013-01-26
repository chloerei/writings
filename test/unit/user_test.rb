require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "get host" do
    user = create :user
    assert_equal "#{user.name}.#{APP_CONFIG['host']}", user.host

    user = create :user, :domain => 'custom.domain'
    assert_equal 'custom.domain', user.host
  end
end
