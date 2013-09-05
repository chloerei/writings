require 'test_helper'

class Importer::JekyllTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @importer = Importer::Jekyll.new(File.open("#{Rails.root}/test/files/_posts.zip", 'rb'))
  end

  test "should import articles" do
    articles = []
    assert_difference "articles.count", 3 do
      @importer.import do |article|
        articles << article
        case article.urlname
        when 'public-article'
          assert_equal 'publish', article.status
          assert_equal Time.parse('2013-06-03'), article.created_at
          assert_equal Time.parse('2013-06-03'), article.published_at
        when 'draft-article'
          assert_equal 'draft', article.status
        end
      end
    end
  end
end
