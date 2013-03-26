class Admin::InvoicesController < Admin::BaseController
  def new
    @user = User.find_by :name => params[:name]
    @invoice = @user.invoices.new
  end

  def create
    @invoice = Invoice.new invoice_params

    if @invoice.save
      redirect_to admin_invoice_url(@invoice)
    else
      render :new
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:plan, :quantity, :price, :balance, :remark, :user_id)
  end
end
