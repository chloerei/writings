class Dashboard::OrdersController < Dashboard::BaseController
  skip_before_filter :require_logined, :require_space_access, :verify_authenticity_token, :only => [:alipay_notify]

  def index
    @orders = @space.orders.showable.desc(:created_at)
  end

  def new
    @order = Order.new
  end

  def create
    @order = @space.orders.new order_param.merge(:plan => :base, :price => 10)

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
    @order = @space.orders.find params[:id]

    callback_params = params.except(*request.path_parameters.keys)
    if callback_params.any? && Alipay::Sign.verify?(callback_params)
      if @order.paid? || @order.completed?
        flash.now[:success] = I18n.t('order_paid_message')
      elsif @order.pending?
        flash.now[:info] = I18n.t('order_pending_message')
      end
    end
  end

  def alipay_notify
    notify_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.verify?(notify_params)
      @order = Order.find params[:out_trade_no]

      case params[:trade_status]
      when 'WAIT_BUYER_PAY'
        @order.update_attribute :trade_no, params[:trade_no]
        @order.pend
      when 'TRADE_FINISHED'
        need_mail = @order.pending?
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

      AlipayNotify.create(
        :verify => true,
        :order  => @order,
        :params => notify_params
      )

      render :text => 'success'
    else
      AlipayNotify.create(
        :verify => false,
        :params => notify_params
      )

      render :text => 'error'
    end
  end

  private

  def order_param
    params.require(:order).permit(:quantity)
  end
end
