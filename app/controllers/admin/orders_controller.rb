class Admin::OrdersController < Admin::BaseController
  def index
    @orders = Order.desc(:created_at).page(params[:page])
  end

  def show
    @order = Order.find params[:id]
  end
end
