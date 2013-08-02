class BillingsController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def show
    @orders = current_user.orders.showable.desc(:created_at).limit(5)
  end
end
