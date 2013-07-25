class BillingsController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def show
    @invoices = current_user.invoices.desc(:created_at).limit(3)
  end
end
