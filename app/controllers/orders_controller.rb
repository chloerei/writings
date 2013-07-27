class OrdersController < ApplicationController
  before_filter :require_logined, :except => [:alipay_notify]
  skip_before_filter :verify_authenticity_token, :only => [:alipay_notify]
  layout 'dashboard'

  def new
    @order = Order.new
  end

  def create
    @order = current_user.orders.new order_param.merge(:plan => :base, :price => 20)

    case @order.quantity
    when 6
      @order.discount = -20
    when 12
      @order.discount = -40
    end

    if [1, 6, 12].include?(@order.quantity) && @order.save
      redirect_to @order.pay_url
    else
      render :new
    end
  end

  def show
    @order = current_user.orders.find params[:id]
  end

  def alipay_notify
    if Alipay::Sign.verify?(params.except(:controller, :action, :host)) && Alipay::Notify.verify?(params)
      @order = Order.find params[:out_trade_no]
      @order.trade_no ||= params[:trade_no]

      case params[:trade_status]
      when 'TRADE_FINISHED'
        @order.complete
      when 'TRADE_CLOSED'
        @order.cancel
      when 'WAIT_SELLER_SEND_GOODS'
        @order.pay
        @order.send_good
        # send good
      else
        # do nothing
      end

      render :text => 'success'
    else
      render :text => 'error'
    end
  end

  private

  def order_param
    params.require(:order).permit(:quantity)
  end
end
