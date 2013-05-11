class ProfilesController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def show
  end

  def update
    current_user.profile.update_attributes profile_params
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :description)
  end
end
