require 'test_helper'

class Importer::JekyllTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @importer = Importer::Jekyll.new(File.open("#{Rails.root}/test/files/blog-jekyll.zip", 'rb'))
  end

  test "should import articles" do
    assert_difference "@space.articles.count" do
      @importer.import do |article|
        article.space = @space
        article.save
        assert_equal Time.parse('2013-06-03'), article.created_at
        assert_equal Time.parse('2013-06-03'), article.published_at
      end
    end
  end
end
