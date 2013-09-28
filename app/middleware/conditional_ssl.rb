class ConditionalSSL < ActionDispatch::SSL
  def call(env)
    request = ActionDispatch::Request.new(env)

    # Only main site enable SSL
    if Rails.env.production? && APP_CONFIG['ssl'] && request.host == APP_CONFIG['host']
      super
    else
      @app.call(env)
    end
  end
end
