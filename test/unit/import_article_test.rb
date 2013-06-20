require 'test_helper'

class ImportArticleTest < ActiveSupport::TestCase
  test "should to article" do
    import_article = create :import_article
    assert_difference "import_article.import_task.space.articles.count" do
      import_article.import
    end
  end
end
