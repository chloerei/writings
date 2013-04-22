class Dashboard::BillingsController < Dashboard::BaseController
  def show
    @invoices = current_user.invoices.desc(:created_at)
  end
end
