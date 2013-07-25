require 'test_helper'

class Alipay::Payments::DualFunTest < ActiveSupport::TestCase
  test "should generate pay url" do
    options = {
      :out_trade_no      => '1',
      :subject           => 'test',
      :logistics_type    => 'POST',
      :logistics_fee     => '0',
      :logistics_payment => 'SELLER_PAY',
      :price             => '0.01',
      :quantity          => 1
    }
    assert_not_nil Alipay::Payments::DualFun.new(options).generate_pay_url
  end
end
