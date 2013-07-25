require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    @user = create :user
    @invoice = create :invoice, :plan => :base, :quantity => 2, :user => @user
  end
  test "init state" do
    assert_equal 'pendding', @invoice.state
    assert @invoice.pendding?
  end

  test "should accept" do
    @invoice.accept
    assert_equal 'accepted', @invoice.state
    assert @invoice.accepted?
    @user.reload
    assert_not_nil @invoice.start_at
    assert_not_nil @invoice.end_at
    assert_not_nil @invoice.accepted_at
    assert_equal @invoice.plan, @user.plan
    assert_not_nil @user.plan_expired_at
  end

  test "should cancel" do
    @invoice.cancel
    assert_equal 'canceled', @invoice.state
    assert @invoice.canceled?
    assert_not_nil @invoice.canceled_at
  end

  test "should pay" do
    @invoice.pay
    assert_equal 'paid', @invoice.state
    assert @invoice.paid?
    assert_equal @invoice.plan, @user.plan
    assert_not_nil @user.plan_expired_at
  end

  test "should add_plan" do
    @invoice.add_plan
    assert_equal @invoice.plan, @user.plan
    assert_not_nil @user.plan_expired_at
  end

  test "should remove_plan" do
    @user.update_attributes :plan_expired_at => Time.now.utc
    time = @user.plan_expired_at
    @invoice.remove_plan
    assert @user.plan_expired_at < time
  end

  test "remove_plan when cancel after pay" do
    @invoice.pay
    time = @user.reload.plan_expired_at
    @invoice.cancel
    assert @user.reload.plan_expired_at < time
  end
end
