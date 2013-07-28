class OrdersController < ApplicationController
  before_filter :require_logined, :except => [:alipay_notify]
  skip_before_filter :verify_authenticity_token, :only => [:alipay_notify]
  layout 'dashboard'

  def index
    @orders = current_user.orders.showable.desc(:created_at)
  end

  def new
    @order = Order.new
  end

  def create
    @order = current_user.orders.new order_param.merge(:plan => :base, :price => 10)

    case @order.quantity
    when 6
      @order.discount = -10
    when 12
      @order.discount = -20
    end

    if [1, 6, 12].include?(@order.quantity) && @order.save
      redirect_to @order.pay_url
    else
      render :new
    end
  end

  def show
    @order = current_user.orders.find params[:id]

    callback_params = params.except(*request.path_parameters.keys)
    if callback_params.any? && Alipay::Sign.verify?(callback_params)
      if @order.paid? || @order.completed?
        flash.now[:success] = I18n.t('order_paid_message')
      elsif @order.pendding?
        flash.now[:info] = I18n.t('order_pendding_message')
      end
    end
  end

  def alipay_notify
    if Alipay::Sign.verify?(params.except(:controller, :action, :host)) && Alipay::Notify.verify?(params)
      @order = Order.find params[:out_trade_no]
      @order.trade_no ||= params[:trade_no]

      case params[:trade_status]
      when 'TRADE_FINISHED'
        need_mail = @order.pendding?
        @order.complete
        SystemMailer.delay.order_payment_success(@order.id.to_s) if need_mail
      when 'TRADE_CLOSED'
        @order.cancel
        SystemMailer.delay.order_cancel(@order.id.to_s)
      when 'WAIT_SELLER_SEND_GOODS'
        @order.pay
        @order.send_good
        SystemMailer.delay.order_payment_success(@order.id.to_s)
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
