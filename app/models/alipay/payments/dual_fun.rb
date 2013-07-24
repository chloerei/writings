class Alipay::Payments::DualFun
  GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'

  MUST_OPTIONS = [
    :service,
    :partner,
    :_input_charset,
    :out_trade_no,
    :subject,
    :payment_type,
    :logistics_type,
    :logistics_fee,
    :logistics_payment,
    :seller_email,
    :price,
    :quantity
  ]

  attr_accessor :options

  def initialize(options)
    self.options = {
      :service        => 'trade_create_by_buyer',
      :_input_charset => 'utf-8',
      :partner        => Alipay.pid,
      :seller_email   => Alipay.email,
      :payment_type   => '1'
    }.merge(options)

    miss_options = []
    MUST_OPTIONS.each do |key|
      miss_options << key if @options[key].blank?
    end

    raise "miss options: #{miss_options.inspect}" if miss_options.any?
  end

  def generate_pay_url
    "#{GATEWAY_URL}?#{query_string}"
  end

  def query_string
    options.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(options)).map do |key, value|
      "#{key}=#{CGI.escape(value)}"
    end.join('&')
  end
end
