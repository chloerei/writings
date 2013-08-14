class Dashboard::BillingsController < Dashboard::BaseController
  before_filter :require_creator

  def show
    @orders = @space.orders.showable.desc(:created_at).limit(5)
  end
end
