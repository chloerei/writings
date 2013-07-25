class InvoicesController < ApplicationController
  before_filter :require_logined, :except => [:alipay_notify]
  skip_before_filter :verify_authenticity_token, :only => [:alipay_notify]
  layout 'dashboard'

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = current_user.invoices.new invoice_param.merge(:plan => :base, :price => 20)

    case @invoice.quantity
    when 6
      @invoice.discount = -20
    when 12
      @invoice.discount = -40
    end

    if [1, 6, 12].include?(@invoice.quantity) && @invoice.save
      redirect_to @invoice.pay_url
    else
      render :new
    end
  end

  def show
    @invoice = current_user.invoices.find params[:id]
  end

  def alipay_notify
    if Alipay::Sign.verify?(params.except(:controller, :action)) && Alipay::Notify.verify?(params)
      @invoice = Invoice.find params[:out_trade_no]
      @invoice.trade_no ||= params[:trade_no]

      case params[:trade_status]
      when 'TRADE_FINISHED'
        @invoice.accept
      when 'TRADE_CLOSED'
        @invoice.cancel
      when 'WAIT_SELLER_SEND_GOODS'
        @invoice.pay
        @invoice.send_good
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

  def invoice_param
    params.require(:invoice).permit(:quantity)
  end
end
