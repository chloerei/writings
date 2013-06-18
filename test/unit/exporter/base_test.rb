require 'test_helper'

class Exporter::BaseTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    2.times { create :article, :space => @space }
    @category = create :category, :space => @space
    2.times { create :article, :space => @space, :category => @category }

    @exporter = Exporter::Base.new(@space)
  end

  test "should init jeykyll exporter" do
    exporter = Exporter::Base.new(@space)
    assert_equal 4, exporter.articles.count

    exporter = Exporter::Base.new(@space, :category => @category)
    assert_equal 2, exporter.articles.count
  end

  test "should prepare tmp" do
    assert_equal "#{Rails.root}/tmp/exporters/base/#{@space.id}", @exporter.tmp_path
    assert File.exists?(@exporter.tmp_path)
  end
end
