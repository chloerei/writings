class ProfilesController < ApplicationController
  before_filter :require_logined

  def show
  end

  def update
    if current_user.profile.update_attributes profile_params
      redirect_to profile_url
    else
      render :show
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :description)
  end
end
