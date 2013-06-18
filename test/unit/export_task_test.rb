require 'test_helper'

class ExportTaskTest < ActiveSupport::TestCase
  def setup
    @space = create :user
    @category = create :category, :space => @space
    2.times { create :article, :space => @space }
  end

  test "should export and store path" do
    task = ExportTask.new(:space => @space, :category => @category, :format => 'jekyll', :user => @user)
    task.export
    assert_equal "#{Rails.root}/data/export_tasks/#{task.id}/jekyll.zip", task.path
    assert File.exists?(task.path)

    task.format = 'wordpress'
    task.export
    assert_equal "#{Rails.root}/data/export_tasks/#{task.id}/wordpress.xml", task.path
    assert File.exists?(task.path)

    task.destroy
    assert !File.exists?(task.output_path)
  end
end
