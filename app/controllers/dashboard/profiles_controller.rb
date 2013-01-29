class Dashboard::ProfilesController < Dashboard::BaseController
  def show
  end

  def update
    if current_user.profile.update_attributes profile_params
      respond_to do |format|
        format.json { render :json => current_user.profile.as_json(:only => [:name, :description]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => 'Validation Failed', :errors => current_user.profile.errors }, :status => 400 }
      end
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :description)
  end
end
