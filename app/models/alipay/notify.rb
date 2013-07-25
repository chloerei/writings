class Alipay::Notify
  def self.verify?(params)
    open("http://notify.alipay.com/trade/notify_query.do?partner=#{APP_CONFIG['alipay']['pid']}&notify_id=#{CGI.escape params[:notify_id].to_s}").read == 'true'
  end
end
