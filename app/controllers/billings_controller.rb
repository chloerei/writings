class BillingsController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def show
    @orders = current_user.orders.where(:state.ne => 'pendding').desc(:created_at).limit(3)
  end
end
