class Alipay::Sign
  def self.generate(params, secret_key)
    query = params.sort.map do |key, value|
      "#{key}=#{value}"
    end.join('&')

    Digest::MD5.hexdigest("#{query}#{secret_key}")
  end

  def self.verify?(params, secret_key)
    params = params.clone
    sign = params.delete(:sign)

    generate(params, secret_key) == sign
  end
end
