class Alipay::Sign
  def self.generate(params)
    query = params.sort.map do |key, value|
      "#{key}=#{value}"
    end.join('&')

    Digest::MD5.hexdigest("#{query}#{APP_CONFIG['alipay']['md5_key']}")
  end

  def self.verify?(params)
    params = params.clone
    params.delete(:sign_type)
    sign = params.delete(:sign)

    generate(params) == sign
  end
end
