require 'test_helper'

class BaseExporterTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @importer = BaseImporter.new(@space, nil)
  end

  test "should prepare tmp_path" do
    assert_equal "#{Rails.root}/tmp/importers/BaseImporter/#{@space.id}", @importer.tmp_path
    assert File.exists?(@importer.tmp_path)
    @importer.clean
    assert !File.exists?(@importer.tmp_path)
  end
end
