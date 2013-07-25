require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create invoice and redirect to alipay" do
    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 1 }
      assert_equal 1, assigns(:invoice).quantity
    end
    assert_redirected_to assigns(:invoice).pay_url
  end

  test "should have discount" do
    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 1 }
      assert_equal 0, assigns(:invoice).discount
    end

    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 6 }
      assert_equal (-20), assigns(:invoice).discount
    end

    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 12 }
      assert_equal (-40), assigns(:invoice).discount
    end

    assert_no_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 11 }
      assert_equal 0, assigns(:invoice).discount
    end
  end

  test "should accept alipay_notify" do
    fake_service
    invoice = create :invoice

    message = {
      :out_trade_no => invoice.id.to_s,
      :trade_status => 'TRADE_FINISHED'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal 'success', @response.body
    assert invoice.reload.accepted?
  end

  test "should cancel alipay_notify" do
    fake_service
    invoice = create :invoice

    message = {
      :out_trade_no => invoice.id.to_s,
      :trade_status => 'TRADE_CLOSED'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal 'success', @response.body
    assert invoice.reload.canceled?
  end

  test "should pay alipay_notify" do
    fake_service
    invoice = create :invoice

    message = {
      :out_trade_no => invoice.id.to_s,
      :trade_status => 'WAIT_SELLER_SEND_GOODS',
      :trade_no     => '1234'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal 'success', @response.body
    assert invoice.reload.paid?
  end

  test "should save trade_no" do
    fake_service
    invoice = create :invoice

    message = {
      :out_trade_no => invoice.id.to_s,
      :trade_status => 'WAIT_SELLER_SEND_GOODS',
      :trade_no     => '123456'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal message[:trade_no], invoice.trade_no
  end

  def fake_service
    FakeWeb.register_uri(
      :get,
      %r|http://notify\.alipay\.com/trade/notify_query.*|,
      :body => "true"
    )
    FakeWeb.register_uri(
      :get,
      %r|https://mapi\.alipay\.com/gateway\.do\?.*send_goods_confirm_by_platform.*|,
      :body => ''
    )
  end
end
