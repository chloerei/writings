class InvitationMailer < ActionMailer::Base
  default :from => "do-not-reply@writings.io"

  def invite(invitation)
    @invitation = invitation
    @workspace = invitation.workspace

    mail(:to => invitation.email,
         :subject => I18n.t('invitation_email_subject', :name => @workspace.name))
  end
end
