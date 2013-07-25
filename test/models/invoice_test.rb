require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  test "init state" do
    invoice = create :invoice
    assert_equal 'pendding', invoice.state
    assert invoice.pendding?
  end

  test "should accept" do
    user = create :user
    invoice = create :invoice, :plan => :base, :quantity => 2, :user => user
    invoice.accept
    assert_equal 'accepted', invoice.state
    assert invoice.accepted?
    user.reload
    assert_equal invoice.plan, user.plan
    assert_not_nil user.plan_expired_at
    assert_not_nil invoice.start_at
    assert_not_nil invoice.end_at
    assert_not_nil invoice.accepted_at
  end

  test "should cancel" do
    invoice = create :invoice
    invoice.cancel
    assert_equal 'canceled', invoice.state
    assert invoice.canceled?
    assert_not_nil invoice.canceled_at
  end
end
