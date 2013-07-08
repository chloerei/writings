require 'test_helper'

class WorkspaceTest < ActiveSupport::TestCase
  test "should add creator to members" do
    user = create :user
    workspace = create :workspace, :creator => user
    assert workspace.reload.members.include?(user)
  end
end
