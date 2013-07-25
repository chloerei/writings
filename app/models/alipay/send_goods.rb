class Alipay::SendGoods
  GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'

  MUST_OPTIONS = [
    :service,
    :partner,
    :_input_charset,
    :trade_no,
    :logistics_name
  ]

  attr_accessor :options

  def initialize(options)
    self.options = options.merge(
      :service        => 'send_goods_confirm_by_platform',
      :_input_charset => 'utf-8',
      :partner        => APP_CONFIG['alipay']['pid'],
      :seller_email   => APP_CONFIG['alipay']['email'],
      :payment_type   => '1'
    )

    miss_options = []
    MUST_OPTIONS.each do |key|
      miss_options << key if self.options[key].blank?
    end

    raise "miss options: #{miss_options.inspect}" if miss_options.any?
  end

  def send_good
    open("#{GATEWAY_URL}?#{query_string}").read
  end

  def query_string
    options.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(options)).map do |key, value|
      CGI.escape("#{key}=#{value.to_s}")
    end.join('&')
  end
end
