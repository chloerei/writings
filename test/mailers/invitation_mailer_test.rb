require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "invite" do
    invitation = create :invitation

    assert_difference "ActionMailer::Base.deliveries.count" do
      InvitationMailer.invite(invitation.id).deliver
    end
  end
end
