require 'test_helper'

class Exporter::BaseTest < ActiveSupport::TestCase
  def setup
    @space = create :space
    2.times { create :article, :space => @space }

    @exporter = Exporter::Base.new(@space)
  end

  test "should init jeykyll exporter" do
    exporter = Exporter::Base.new(@space)
    assert_equal 2, exporter.articles.count
  end

  test "should prepare tmp" do
    @exporter.prepare
    assert File.exists?(@exporter.tmp_path)
    @exporter.clean
    assert !File.exists?(@exporter.tmp_path)
  end
end
