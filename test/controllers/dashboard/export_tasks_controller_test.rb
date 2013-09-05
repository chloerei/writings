require 'test_helper'

class Dashboard::ExportTasksControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    login_as @space.user
  end

  test "should create task" do
    assert_difference ["@space.export_tasks.count", "Sidekiq::Extensions::DelayedClass.jobs.size"] do
      post :create, :space_id => @space, :export_task => { :format => 'jekyll' }
    end
  end
end
