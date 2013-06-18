require 'test_helper'

class Exporter::WordpressTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    2.times { create :article, :space => @space }
    @category = create :category, :space => @space
    2.times { create :article, :space => @space, :category => @category }

    @exporter = Exporter::Wordpress.new(@space)
  end

  test "should export" do
    path = @exporter.export
    assert_equal "#{@exporter.tmp_path}/output.xml", path
    assert File.exists?(path)
  end
end
