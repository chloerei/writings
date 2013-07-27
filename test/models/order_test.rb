require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  def setup
    @user = create :user
    @order = create :order, :plan => :base, :quantity => 2, :user => @user
  end
  test "init state" do
    assert_equal 'pendding', @order.state
    assert @order.pendding?
  end

  test "should complete" do
    @order.complete
    assert_equal 'completed', @order.state
    assert @order.completed?
    @user.reload
    assert_not_nil @order.start_at
    assert_not_nil @order.end_at
    assert_not_nil @order.completed_at
    assert_equal @order.plan, @user.plan
    assert_not_nil @user.plan_expired_at
  end

  test "should cancel" do
    @order.cancel
    assert_equal 'canceled', @order.state
    assert @order.canceled?
    assert_not_nil @order.canceled_at
  end

  test "should pay" do
    @order.pay
    assert_equal 'paid', @order.state
    assert @order.paid?
    assert_equal @order.plan, @user.plan
    assert_not_nil @user.plan_expired_at
  end

  test "should add_plan" do
    @order.add_plan
    assert_equal @order.plan, @user.plan
    assert_not_nil @user.plan_expired_at
    assert_not_nil @order.start_at
    assert_not_nil @order.end_at
  end

  test "should remove_plan" do
    @user.update_attributes :plan_expired_at => Time.now.utc
    time = @user.plan_expired_at
    @order.remove_plan
    assert @user.plan_expired_at < time
  end

  test "remove_plan when cancel after pay" do
    @order.pay
    time = @user.reload.plan_expired_at
    @order.cancel
    assert @user.reload.plan_expired_at < time
  end

  test "should not cancel after completed" do
    @order.complete
    assert @order.completed?
    @order.cancel
    assert !@order.canceled?
  end

  test "should not paid after completed" do
    @order.complete
    assert @order.completed?
    @order.pay
    assert !@order.paid?
  end
end
