require 'test_helper'

class Alipay::Payments::DualFunTest < ActiveSupport::TestCase
  test "should generate pay url" do
    options = {
      :_input_charset => 'utf-8',
      :payment_type => '1',
      :partner    => '1234'
    }
    assert_not_nil Alipay::Payments::DualFun.new(options).generate_pay_url
  end
end
