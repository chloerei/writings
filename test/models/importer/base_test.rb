require 'test_helper'

class Importer::BaseTest < ActiveSupport::TestCase
  def setup
    @importer = Importer::Base.new(nil)
  end

  test "should prepare tmp_path" do
    assert File.exists?(@importer.tmp_path)
  end
end
