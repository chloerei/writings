require 'test_helper'

class Dashboard::ImportTasksControllerTest < ActionController::TestCase
  def setup
    @space = create :space
    login_as @space.user
  end

  test "should create task" do
    assert_difference ["@space.import_tasks.count", "Sidekiq::Extensions::DelayedClass.jobs.size"] do
      post :create, :space_id => @space, :import_task => {
        :format => 'jekyll',
        :file   => upload_file("#{Rails.root}/test/files/_posts.zip")
      }
    end
  end

  test "should confirm articles" do
    import_task = create :import_task, :space => @space, :user => @space.user
    import_task.import

    get :show, :space_id => @space, :id => import_task
    assert_response :success, @response.body

    assert_difference "@space.articles.count" do
      post :confirm, :space_id => @space, :id => import_task, :ids => import_task.import_article_ids
    end
  end
end
