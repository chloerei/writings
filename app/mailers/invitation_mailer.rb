class InvitationMailer < ActionMailer::Base
  default :from => "do-not-reply@writings.io"

  def invite(invitation_id)
    @invitation = Invitation.find_by :id => invitation_id
    @workspace = @invitation.workspace
    I18n.locale = @workspace.creator.locale

    mail(:to => @invitation.email,
         :subject => I18n.t('invitation_email_subject', :name => @workspace.name))
  end
end
