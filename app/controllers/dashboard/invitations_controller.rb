class Dashboard::InvitationsController < Dashboard::BaseController
  before_filter :require_workspace
  before_filter :require_owner, :only => [:create]

  def create
    exists_emails = [@space.owner.email]
    exists_emails += @space.members.map(&:email).map(&:downcase)

    @invitations = params[:emails].map { |email|
      if email.present? && !exists_emails.include?(email.downcase)
        @space.invitations.create :email => email
      end
    }.compact.find_all { |invitation| invitation.persisted? }

    logger.info @invitation.inspect

    respond_to do |format|
      format.js
    end
  end

  private

  def invitation_params
    params.require(:emails)
  end
end
