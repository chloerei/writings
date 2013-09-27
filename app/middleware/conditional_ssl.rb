class ConditionalSSL < ActionDispatch::SSL
  def call(env)
    request = ActionDispatch::Request.new(env)

    if Rails.env.production? && APP_CONFIG['ssl'] && request.host == APP_CONFIG['host']
      super
    else
      @app.call(env)
    end
  end
end
