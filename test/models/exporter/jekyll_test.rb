require 'test_helper'

class Exporter::JekyllTest < ActiveSupport::TestCase
  def setup
    @space = create :space
    2.times { create :article, :space => @space }
    @category = create :category, :space => @space
    2.times { create :article, :space => @space, :category => @category }

    @exporter = Exporter::Jekyll.new(@space, :category => @category)
  end

  test "should export" do
    @exporter.export
    assert File.exists?("#{@exporter.output_path}/jekyll.zip")
  end
end
