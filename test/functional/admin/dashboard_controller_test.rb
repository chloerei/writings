require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase
  def setup
    APP_CONFIG['admin_emails'] = %w(admin@writings.io)
    @admin = create :user, :email => 'admin@writings.io'
    @user = create :user
  end
end
