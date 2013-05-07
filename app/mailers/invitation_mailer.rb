class InvitationMailer < ActionMailer::Base
  default :from => "do-not-reply@writings.io"

  def invite(invitation)
    @invitation = invitation
    @workspace = invitation.workspace

    mail(:to => invitation.email, :subject => "You're invited to the #{@workspace.name} workspace")
  end
end
