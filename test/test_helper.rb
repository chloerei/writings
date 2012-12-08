ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def teardown
    Mongoid.default_session.collections.select{|c| c.name !~ /system/}.each(&:drop)
  end
end

class ActionController::TestCase
  attr_reader :controller
  delegate :login_as, :logout, :current_user, :logined?, :to => :controller
end
