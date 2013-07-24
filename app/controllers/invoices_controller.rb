class InvoicesController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = current_user.invoices.new invoice_param.merge(:plan => :base, :price => 20)

    case @invoice.quantity
    when 6
      @invoice.discount = 20
    when 12
      @invoice.discount = 40
    end

    if [1, 6, 12].include?(@invoice.quantity) && @invoice.save
      redirect_to @invoice.pay_url
    else
      render :new
    end
  end

  private

  def invoice_param
    params.require(:invoice).permit(:quantity)
  end
end
