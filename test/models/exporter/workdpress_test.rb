require 'test_helper'

class Exporter::WordpressTest < ActiveSupport::TestCase
  def setup
    @space = create :space
    2.times { create :article, :space => @space }
    @category = create :category, :space => @space
    2.times { create :article, :space => @space, :category => @category }

    @exporter = Exporter::Wordpress.new(@space)
  end

  test "should export" do
    @exporter.export
    assert File.exists?("#{@exporter.output_path}/wordpress.xml")
  end
end
