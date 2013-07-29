class Alipay::Service
  GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'

  DUAL_FUN_PAYMENT_REQUIRED_OPTIONS = %w( service partner _input_charset out_trade_no subject payment_type logistics_type logistics_fee logistics_payment seller_email price quantity )
  def self.dual_fun_payment_url(options = {})
    options = {
      :service        => 'trade_create_by_buyer',
      :_input_charset => 'utf-8',
      :partner        => Alipay.pid,
      :seller_email   => Alipay.seller_email,
      :payment_type   => '1'
    }.merge(options.symbolize_keys)

    check_required_options(options, DUAL_FUN_PAYMENT_REQUIRED_OPTIONS)

    "#{GATEWAY_URL}?#{query_string(options)}"
  end

  SEND_GOODS_CONFIRM_BY_PLATFORM_REQUIRED_OPTIONS = %w( service partner _input_charset trade_no logistics_name )
  def self.send_goods_confirm_by_platform(options)
    options = {
      :service        => 'send_goods_confirm_by_platform',
      :partner        => Alipay.pid,
      :_input_charset => 'utf-8'
    }.merge(options.symbolize_keys)

    check_required_options(options, SEND_GOODS_CONFIRM_BY_PLATFORM_REQUIRED_OPTIONS)

    if options[:transport_type].nil? && options[:create_transport_type].nil?
      warn("Ailpay Warn: transport_type or create_transport_type must have one")
    end

    open("#{GATEWAY_URL}?#{query_string(options)}").read
  end

  def self.query_string(options)
    options.merge(:sign_type => 'MD5', :sign => Alipay::Sign.generate(options)).map do |key, value|
      "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
    end.join('&')
  end

  def self.check_required_options(options, names)
    names.each do |name|
      warn("Ailpay Warn: missing required option: #{name}") unless options.has_key?(name.to_sym)
    end
  end
end
