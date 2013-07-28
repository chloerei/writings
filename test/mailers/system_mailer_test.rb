require 'test_helper'

class SystemMailerTest < ActionMailer::TestCase
  test "order_payment_success email" do
    order = create :order
    assert_difference "ActionMailer::Base.deliveries.count" do
      SystemMailer.order_payment_success(order.id).deliver
    end
  end
end
