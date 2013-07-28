require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should get index page" do
    create :order, :user => @user
    get :index
    assert_response :success, @response.body
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create order and redirect to alipay" do
    assert_difference "@user.orders.count" do
      post :create, :order => { :quantity => 1 }
      assert_equal 1, assigns(:order).quantity
    end
    assert_redirected_to assigns(:order).pay_url
  end

  test "should have discount" do
    assert_difference "@user.orders.count" do
      post :create, :order => { :quantity => 1 }
      assert_equal 0, assigns(:order).discount
    end

    assert_difference "@user.orders.count" do
      post :create, :order => { :quantity => 6 }
      assert_equal (-10), assigns(:order).discount
    end

    assert_difference "@user.orders.count" do
      post :create, :order => { :quantity => 12 }
      assert_equal (-20), assigns(:order).discount
    end

    assert_no_difference "@user.orders.count" do
      post :create, :order => { :quantity => 11 }
      assert_equal 0, assigns(:order).discount
    end
  end

  test "should complete alipay_notify" do
    fake_service
    order = create :order
    logout

    message = {
      :out_trade_no => order.id.to_s,
      :trade_status => 'TRADE_FINISHED'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal 'success', @response.body
    assert order.reload.completed?
  end

  test "should cancel alipay_notify" do
    fake_service
    order = create :order
    logout

    message = {
      :out_trade_no => order.id.to_s,
      :trade_status => 'TRADE_CLOSED'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal 'success', @response.body
    assert order.reload.canceled?
  end

  test "should pay alipay_notify" do
    fake_service
    order = create :order
    logout

    message = {
      :out_trade_no => order.id.to_s,
      :trade_status => 'WAIT_SELLER_SEND_GOODS',
      :trade_no     => '1234'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal 'success', @response.body
    assert order.reload.paid?
  end

  test "should save trade_no" do
    fake_service
    order = create :order
    logout

    message = {
      :out_trade_no => order.id.to_s,
      :trade_status => 'WAIT_SELLER_SEND_GOODS',
      :trade_no     => '123456'
    }
    post :alipay_notify, message.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(message))
    assert_equal message[:trade_no], order.trade_no
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
