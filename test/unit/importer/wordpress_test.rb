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
      end
    end
  end
end
