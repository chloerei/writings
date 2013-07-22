class ConditionalSSL < ActionDispatch::SSL
  def call(env)
    request = ActionDispatch::Request.new(env)

    if Rails.env.production? && request.host == APP_CONFIG['host']
      super
    else
      @app.call(env)
    end
  end
end
