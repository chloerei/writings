require 'test_helper'

class Importer::BaseTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @importer = Importer::Base.new(@space, nil)
  end

  test "should prepare tmp_path" do
    assert_equal "#{Rails.root}/tmp/importers/base/#{@space.id}", @importer.tmp_path
    assert File.exists?(@importer.tmp_path)
  end
end
