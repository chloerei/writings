class Alipay::Sign
  def self.generate(params)
    query = params.sort.map do |key, value|
      "#{key}=#{value}"
    end.join('&')

    Digest::MD5.hexdigest("#{query}#{Alipay.md5_key}").upcase
  end

  def self.verify?(params)
    params = params.clone
    sign = params.delete(:sign)

    generate(params) == sign
  end
end
