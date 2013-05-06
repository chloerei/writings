require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  test "should generate token" do
    invitation = create :invitation
    assert_not_nil invitation.token
  end
end
