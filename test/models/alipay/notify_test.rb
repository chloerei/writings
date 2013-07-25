require 'test_helper'

class Alipay::NotifyTest < ActiveSupport::TestCase
  test "should verify notify" do
    FakeWeb.register_uri(:get, "http://notify.alipay.com/trade/notify_query.do?partner=#{APP_CONFIG['alipay']['pid']}&notify_id=true_id", :body => "true")
    FakeWeb.register_uri(:get, "http://notify.alipay.com/trade/notify_query.do?partner=#{APP_CONFIG['alipay']['pid']}&notify_id=fake_id", :body => "false")

    assert Alipay::Notify.verify?(:notify_id => 'true_id')
    assert !Alipay::Notify.verify?(:notify_id => 'fake_id')
  end
end
