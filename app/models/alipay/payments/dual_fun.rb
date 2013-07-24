class Alipay::Payments::DualFun
  DEFAULT_OPTIONS = {
    :service        => 'trade_create_by_buyer',
    :_input_charset => 'utf-8',
    :sign_type      => 'MD5'
  }
  GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'

  def initialize(options)
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def generate_pay_url
    "#{GATEWAY_URL}?#{query_string}"
  end

  def query_string
    @options.merge(:sign => Alipay::Sign.generate(@options)).map do |key, value|
      "#{key}=#{CGI.escape(value)}"
    end.join('&')
  end
end
