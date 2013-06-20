require 'test_helper'

class ImportTaskTest < ActiveSupport::TestCase
  def setup
    @user = create :user
  end

  test "should import jekyll" do
    task = create :import_task, :space => @user, :file => File.open("#{Rails.root}/test/files/_posts.zip"), :format => 'jekyll'

    assert_no_difference "@user.articles.count" do
      assert_difference "@user.articles.unscoped.count", 3 do
        task.import
      end
    end

    assert_equal 3, task.articles.count
  end

  test "should import wordpress" do
    task = create :import_task, :space => @user, :file => File.open("#{Rails.root}/test/files/wordpress.xml"), :format => 'wordpress'

    assert_no_difference "@user.articles.count" do
      assert_difference ["@user.articles.unscoped.count"] do
        task.import
      end
    end

    assert_equal 1, task.articles.count
  end

  test "should confirm articles" do
    import_task = create :import_task, :space => @user, :user => @user
    import_task.import
    assert_equal 1, import_task.articles.count

    assert_difference ["@user.articles.count"] do
      import_task.confirm(import_task.article_ids)
    end

    assert_no_difference "@user.articles.count" do
      import_task.destroy
    end
  end

  test "should send email after import success" do
    import_task = create :import_task
    assert_difference "Sidekiq::Extensions::DelayedMailer.jobs.size" do
      import_task.import
    end
  end
end
