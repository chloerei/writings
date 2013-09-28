require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

Bundler.require(:default, Rails.env)

module Writings
  class Application < Rails::Application
    config.middleware.insert_before Rack::Runtime, 'ConditionalSSL'
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'zh-CN'

    config.generators do |g|
      g.test_framework :test_unit, :fixture_replacement => :factory_girl
      g.assets false
      g.helper false
    end
  end
end

SafeYAML::OPTIONS[:default_mode] = :unsafe
ALLOW_LOCALE = Dir["#{Rails.root}/config/locales/*.yml"].map {|f| File.basename(f).split('.').first}
APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
DOMAIN_LENGTH = APP_CONFIG["host"].split('.').length - 1
