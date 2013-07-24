require 'test_helper'

class Alipay::SignTest < ActiveSupport::TestCase
  def setup
    @params = {
      :service => 'test',
      :partner => '123'
    }
    @sign = Digest::MD5.hexdigest("partner=123&service=test#{Alipay.md5_key}")
  end

  test "should generate sign" do
    assert_equal @sign, Alipay::Sign.generate(@params)
  end

  test "should verify sign" do
    assert Alipay::Sign.verify?(@params.merge(:sign => @sign))
  end
end
