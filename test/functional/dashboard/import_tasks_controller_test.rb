require 'test_helper'

class Dashboard::ImportTasksControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should create task" do
    assert_difference ["@user.import_tasks.count", "Sidekiq::Extensions::DelayedClass.jobs.size"] do
      post :create, :space_id => @user, :import_task => { :format => 'jekyll', :file => File.open("#{Rails.root}/test/files/blog-jekyll.zip") }
    end
  end
end
