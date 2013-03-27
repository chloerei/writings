class Dashboard::BillingsController < Dashboard::BaseController
  def show
    @invoices = current_user.invoices.desc(:created_at)
  end

  def create
    if params[:plan] == 'base' && current_user.plan_expired_at.blank?
      current_user.update_attribute :plan, :base
      current_user.update_attribute :plan_expired_at, 7.days.from_now
    end
    redirect_to dashboard_billing_url
  end
end
