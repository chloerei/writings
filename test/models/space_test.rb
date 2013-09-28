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

  test "in_plan?" do
    assert create(:space).in_plan?(:free)
    assert create(:space, :plan => :base).in_plan?(:free)
    assert create(:space, :plan => :base, :plan_expired_at => 1.day.ago).in_plan?(:free)
    assert create(:space, :plan => :base, :plan_expired_at => 1.day.from_now).in_plan?(:base)
  end

  test "domain_enabled?" do
    assert !create(:space).domain_enabled?
    assert !create(:space, :plan => :base).domain_enabled?
    assert !create(:space, :plan => :base, :plan_expired_at => 1.day.ago).domain_enabled?
    assert create(:space, :plan => :base, :plan_expired_at => 1.day.from_now).domain_enabled?
  end

  test "host" do
    assert_equal "name.#{APP_CONFIG["host"]}", create(:space, :name => 'name').host
    assert_equal "name2.#{APP_CONFIG["host"]}", create(:space, :name => 'name2', :domain => 'custom2.domain').host
    assert_equal "custom3.domain", create(:space, :domain => 'custom3.domain', :plan => :base, :plan_expired_at => 1.day.from_now).host
  end
end
