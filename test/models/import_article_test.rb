require 'test_helper'

class ImportArticleTest < ActiveSupport::TestCase
  test "should to article" do
    import_article = create :import_article
    assert_difference "import_article.import_task.space.articles.count" do
      import_article.import
    end
  end

  test "should import category" do
    import_article = create :import_article, :category => 'Ruby'
    assert_difference "import_article.import_task.space.categories.count" do
      import_article.import
    end
    assert_equal import_article.import_task.user, Article.last.user

    # no duplicate
    assert_no_difference "import_article.import_task.space.categories.count" do
      import_article.import
    end
  end
end
