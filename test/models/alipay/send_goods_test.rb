require 'test_helper'

class Alipay::SendGoodsTest < ActiveSupport::TestCase
  test "should send_goods" do
    body = <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <alipay>
        <is_success>T</is_success>
      </alipay>
    EOF
    FakeWeb.register_uri(
      :get,
      %r|https://mapi\.alipay\.com/gateway\.do.*|,
      :body => body
    )

    assert_equal body, Alipay::SendGoods.new(:trade_no => 'trade_no_id', :logistics_name => 'writings.io').send_good
  end
end
