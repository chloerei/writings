Recaptcha.configure do |config|
  config.public_key  = APP_CONFIG['recaptcha']['public_key']
  config.private_key = APP_CONFIG['recaptcha']['private_key']
  config.use_ssl_by_default = true
end
