require 'test_helper'

class JekyllExporterTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    2.times { create :article, :space => @space }
    @category = create :category, :space => @space
    2.times { create :article, :space => @space, :category => @category }

    @exporter = JekyllExporter.new(@space)
  end

  test "should init jeykyll exporter" do
    exporter = JekyllExporter.new(@space)
    assert_equal 4, exporter.articles.count

    exporter = JekyllExporter.new(@space, :category => @category)
    assert_equal 2, exporter.articles.count
  end

  test "should prepare tmp" do
    assert File.exists?("#{Rails.root}/tmp/exporters/jekyll/#{@space.id}")
  end

  test "should export" do
    path = @exporter.export
    assert_equal "#{Rails.root}/tmp/exporters/jekyll/#{@space.id}/output.zip", path
    assert File.exists?(path)
  end
end
