class InvitationMailer < ActionMailer::Base
  default :from => "do-not-reply@writings.io"

  def invite(invitation_id)
    @invitation = Invitation.find_by :id => invitation_id
    @space = @invitation.space
    I18n.locale = @space.user.locale

    mail(:to => @invitation.email,
         :subject => I18n.t('invitation_email_subject', :name => @space.display_name))
  end
end
