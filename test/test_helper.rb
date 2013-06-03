ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'sidekiq/testing'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def teardown
    Mongoid.default_session.collections.select{|c| c.name !~ /system/}.each(&:drop)
  end
end

class ActionController::TestCase
  attr_reader :controller
  delegate :login_as, :logout, :current_user, :logined?, :to => :controller

  def assert_require_logined(user = create(:user))
    logout
    yield
    assert_redirected_to login_url
    login_as user
    yield
  end
end

Fog.mock!

connection = Fog::Storage.new(
  :provider               => 'AWS',
  :aws_access_key_id      => APP_CONFIG['s3']['aws_access_key_id'],
  :aws_secret_access_key  => APP_CONFIG['s3']['aws_secret_access_key'],
  :region                 => APP_CONFIG['s3']['region']
)

connection.directories.create(:key => APP_CONFIG['s3']['fog_directory'])
