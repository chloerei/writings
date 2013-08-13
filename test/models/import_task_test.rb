require 'test_helper'

class ImportTaskTest < ActiveSupport::TestCase
  def setup
    @user = create :user
    @space = create :space, :user => @user
  end

  test "should import jekyll" do
    task = create :import_task, :space => @space, :file => File.open("#{Rails.root}/test/files/_posts.zip"), :format => 'jekyll'

    assert_no_difference "@space.articles.count" do
      assert_difference "task.import_articles.count", 3 do
        task.import
      end
    end

    assert_equal 3, task.import_articles.count
  end

  test "should import wordpress" do
    task = create :import_task, :space => @space, :file => File.open("#{Rails.root}/test/files/wordpress.xml"), :format => 'wordpress'

    assert_no_difference "@space.articles.count" do
      assert_difference ["task.import_articles.count"] do
        task.import
      end
    end

    assert_equal 1, task.import_articles.count
  end

  test "should confirm articles" do
    import_task = create :import_task, :space => @space, :user => @user
    import_task.import
    assert_equal 1, import_task.import_articles.count

    assert_difference "@space.articles.count" do
      import_task.confirm(import_task.import_article_ids)
    end

    assert_difference "import_task.import_articles.count", -1 do
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
