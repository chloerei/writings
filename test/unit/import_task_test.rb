require 'test_helper'

class ImportTaskTest < ActiveSupport::TestCase
  def setup
    @space = create :user
  end

  test "should import jekyll" do
    task = ImportTask.new(
      :space  => @space,
      :file   => File.open("#{Rails.root}/test/files/blog-jekyll.zip"),
      :format => 'jekyll'
    )

    assert_no_difference "@space.articles.count" do
      assert_difference "@space.articles.unscoped.count" do
        task.import
      end
    end

    assert_equal 1, task.articles.count
  end

  test "should import wordpress" do
    task = ImportTask.new(
      :space  => @space,
      :file   => File.open("#{Rails.root}/test/files/blog-wordpress.xml"),
      :format => 'wordpress'
    )

    assert_no_difference "@space.articles.count" do
      assert_difference "@space.articles.unscoped.count" do
        task.import
      end
    end

    assert_equal 1, task.articles.count
  end
end
