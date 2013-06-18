require 'test_helper'

class Exporter::JekyllTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    2.times { create :article, :space => @space }
    @category = create :category, :space => @space
    2.times { create :article, :space => @space, :category => @category }

    @exporter = Exporter::Jekyll.new(@space)
  end

  test "should export" do
    path = @exporter.export
    assert_equal "#{@exporter.tmp_path}/output.zip", path
    assert File.exists?(path)
  end
end
