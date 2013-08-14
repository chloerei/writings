require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  def setup
    @space = create :space
    @order = create :order, :plan => :base, :quantity => 2, :space => @space
  end

  test "init state" do
    assert_equal 'opening', @order.state
  end

  test "should pend" do
    @order.pend
    assert_equal 'pending', @order.state
    assert @order.pending?
  end

  test "should complete" do
    @order.update_attribute :state, 'pending'
    @order.complete
    assert_equal 'completed', @order.state
    assert @order.completed?
    @space.reload
    assert_not_nil @order.start_at
    assert_not_nil @order.completed_at
    assert_equal @order.plan, @space.plan
    assert_not_nil @space.plan_expired_at
  end

  test "should cancel" do
    @order.update_attribute :state, 'pending'
    @order.cancel
    assert_equal 'canceled', @order.state
    assert @order.canceled?
    assert_not_nil @order.canceled_at
  end

  test "should pay" do
    @order.update_attribute :state, 'pending'
    @order.pay
    assert_equal 'paid', @order.state
    assert @order.paid?
    assert_equal @order.plan, @space.plan
    assert_not_nil @space.plan_expired_at
  end

  test "should add_plan" do
    @order.add_plan
    assert_equal @order.plan, @space.plan
    assert_not_nil @space.plan_expired_at
    assert_not_nil @order.start_at
  end

  test "should add_plan if plan exists" do
    time = 1.day.from_now
    @space.update_attributes :plan => :base, :plan_expired_at => time
    assert_difference "@space.plan_expired_at", @order.quantity.months do
      @order.add_plan
    end
    assert_equal @order.plan, @space.plan
    assert_equal time, @order.start_at
  end

  test "should remove_plan" do
    @order.add_plan
    assert_difference "@space.reload.plan_expired_at", -@order.quantity.month do
      @order.remove_plan
    end
  end

  test "should remove_plan and reset other order after this" do
    @order.add_plan
    other_order = create :order, :space => @space, :quantity => 1
    other_order.add_plan
    assert other_order.start_at > @order.start_at
    assert_not_nil other_order.start_at
    assert_difference "other_order.reload.start_at", -@order.quantity.month do
      @order.remove_plan
    end
  end

  test "remove_plan when cancel after pay" do
    @order.update_attribute :state, 'pending'
    @order.pay
    assert_difference "@space.reload.plan_expired_at", -@order.quantity.month do
      @order.cancel
    end
  end

  test "should not cancel after completed" do
    @order.update_attribute :state, 'completed'
    assert @order.completed?
    @order.cancel
    assert !@order.canceled?
  end

  test "should not paid after completed" do
    @order.update_attribute :state, 'completed'
    assert @order.completed?
    @order.pay
    assert !@order.paid?
  end
end
