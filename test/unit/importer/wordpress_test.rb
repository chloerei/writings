require 'test_helper'

class ImporterWordpressTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @importer = Importer::Wordpress.new(File.open("#{Rails.root}/test/files/blog-wordpress.xml", 'rb'))
  end

  test "should import articles" do
    assert_difference "@space.articles.count" do
      @importer.import do |article|
        article.space = @space
        article.save
        assert_equal Time.parse('2013-06-03 18:16:44 +0800'), article.created_at
        assert_equal Time.parse('Tue, 04 Jun 2013 09:00:57 -0000'), article.published_at
      end
    end
  end
end
