class Dashboard::InvitationsController < Dashboard::BaseController
  before_filter :require_workspace
  before_filter :require_owner, :only => [:create]

  def create
    @invitations = params[:emails].map do |email|
      @space.invitations.create :email => email
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def invitation_params
    params.require(:emails)
  end
end
