require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  test "init state" do
    invoice = create :invoice
    assert_equal :pendding, invoice.state
  end

  test "should approve" do
    user = create :user
    invoice = create :invoice, :plan => :base, :quantity => 2, :user => user
    invoice.approve
    assert_equal :approved, invoice.state
    user.reload
    assert_equal invoice.plan, user.plan
    assert_not_nil user.plan_expired_at
    assert_not_nil invoice.start_at
    assert_not_nil invoice.end_at
    assert_not_nil invoice.approved_at
  end
end
