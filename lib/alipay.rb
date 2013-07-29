require 'alipay/sign'
require 'alipay/service'
require 'alipay/notify'

module Alipay
  class << self
    attr_accessor :pid
    attr_accessor :key
    attr_accessor :seller_email
  end
end
