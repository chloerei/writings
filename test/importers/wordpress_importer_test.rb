require 'test_helper'

class WordpressImporterTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @importer = WordpressImporter.new(@space, File.open("#{Rails.root}/test/files/blog-wordpress.xml", 'rb'))
  end

  test "should import articles" do
    assert_difference "@space.articles.count" do
      @importer.import
    end
  end
end
