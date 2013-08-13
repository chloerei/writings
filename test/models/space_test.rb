require 'test_helper'

class SpaceTest < ActiveSupport::TestCase
  test "should add creator to members" do
    user = create :user
    space = create :space, :user => user
    assert space.reload.members.include?(user)
  end

  test "domain validates" do
    space = create :space
    space.domain = "noallow.#{APP_CONFIG['host']}"
    assert !space.valid?
    space.domain = "http://domain.com"
    assert !space.valid?
    space.domain = "domain.com/some"
    assert !space.valid?
    space.domain = "domain.com"
    assert space.valid?
  end

  test "test plan storage limit" do
    space = create :space
    assert_equal :free, space.plan
    assert_equal 10.megabytes, space.storage_limit
  end
end
