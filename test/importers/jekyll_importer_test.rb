require 'test_helper'

class BaseExporterTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @importer = JekyllImporter.new(@space, File.open("#{Rails.root}/test/files/blog-jekyll.zip", 'rb'))
  end

  test "should import articles" do
    assert_difference "@space.articles.count" do
      @importer.import
    end
  end
end
