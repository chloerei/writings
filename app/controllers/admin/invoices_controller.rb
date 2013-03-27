class Admin::InvoicesController < Admin::BaseController
  def index
    @invoices = Invoice.desc(:created_at).page(params[:page]).per(25)
  end

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

  def show
    @invoice = Invoice.find params[:id]
  end

  def destroy
    @invoice = Invoice.find params[:id]
    @invoice.destroy
    redirect_to admin_user_path(@invoice.user)
  end

  def approve
    @invoice = Invoice.find params[:id]
    @invoice.approve
    redirect_to admin_invoice_url(@invoice)
  end

  private

  def invoice_params
    params.require(:invoice).permit(:plan, :quantity, :price, :balance, :remark, :user_id)
  end
end
