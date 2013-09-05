require 'test_helper'

class Exporter::JekyllTest < ActiveSupport::TestCase
  def setup
    @space = create :space
    2.times { create :article, :space => @space }

    @exporter = Exporter::Jekyll.new(@space)
  end

  test "should export" do
    @exporter.export
    assert File.exists?("#{@exporter.output_path}/jekyll.zip")
  end
end
