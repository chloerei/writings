class Admin::AlipayNotifiesController < Admin::BaseController
  def index
    @alipay_notifies = AlipayNotify.desc(:created_at).page(params[:page])
  end

  def show
    @alipay_notify = AlipayNotify.find params[:id]
  end
end
