require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "get host" do
    user = create :user
    assert_equal "#{user.name}.#{APP_CONFIG['host']}", user.host

    user = create :user, :domain => 'custom.domain'
    assert_equal 'custom.domain', user.host
  end

  test "domain validates" do
    user = create :user, :password => '12345678', :password_confirmation => '12345678'
    user.current_password = '12345678'
    assert user.valid?, user.errors.full_messages.to_s
    user.domain = "noallow.#{APP_CONFIG['host']}"
    assert !user.valid?
    user.domain = "http://domain.com"
    assert !user.valid?
    user.domain = "domain.com/some"
    assert !user.valid?
    user.domain = "domain.com"
    assert user.valid?
  end

  test "test user plan store limit" do
    user = create :user
    assert_equal :free, user.plan
    assert_equal 100.megabytes, user.store_limit
  end
end
