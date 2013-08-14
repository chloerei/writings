class Dashboard::InvitationsController < Dashboard::BaseController
  before_filter :require_creator, :require_plan, :only => [:create, :destroy, :resend]
  skip_filter :require_logined, :require_space_access, :only => [:show, :accept, :join]

  def show
    @invitation = @space.invitations.find_by :token => params[:id]

    if logined? and @space.members.include?(current_user)
      redirect_to dashboard_root_url
    end
  end

  def create
    exists_emails = @space.members.map(&:email).map(&:downcase)

    @invitations = params[:emails].map { |email|
      if email.present? && !exists_emails.include?(email.downcase)
        @space.invitations.create :email => email, :message => params[:message]
      end
    }.compact.find_all { |invitation| invitation.persisted? }
  end

  def destroy
    @invitation = @space.invitations.find params[:id]
    @invitation.destroy
  end

  def resend
    @invitation = @space.invitations.find params[:id]
    @invitation.send_mail
  end

  def accept
    @invitation = @space.invitations.find_by :token => params[:id]
    unless @space.members.include? current_user
      @space.members << current_user
      @invitation.destroy
    end
  end

  def join
    @invitation = @space.invitations.find_by :token => params[:id]

    if logined?
      render :js => "Turbolinks.visit('#{dashboard_invitation_url(@space, @invitation)}');"
    else
      @user = User.new user_params
      if @user.save
        login_as @user
        @space.members << current_user
        @invitation.destroy
      end
    end
  end

  private

  def require_plan
    if @space.in_plan?(:free)
      render :js => "Turbolinks.visit('#{dashboard_members_url(@space)}');"
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
