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

  test "should confirm articles" do
    import_task = create :import_task, :space => @user, :user => @user
    import_task.import

    assert_difference "@user.articles.count" do
      post :confirm, :space_id => @user, :id => import_task, :ids => import_task.article_ids
    end
  end
end
