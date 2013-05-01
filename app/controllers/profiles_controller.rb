class ProfilesController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def show
  end

  def update
    if current_user.profile.update_attributes profile_params
      respond_to do |format|
        format.json { render :json => current_user.profile.as_json(:only => [:name, :description]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => current_user.profile.errors.full_messages.join }, :status => 400 }
      end
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :description)
  end
end
