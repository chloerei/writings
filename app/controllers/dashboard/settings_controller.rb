class Dashboard::SettingsController < Dashboard::BaseController
  def show
  end

  def update
    if @space.update_attributes space_params
      respond_to do |format|
        format.json { render :json => @space.as_json(:only => [:domain, :disqus_shortname]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => @space.errors.full_messages.join }, :status => 400}
      end
    end
  end

  private

  def space_params
    case @space
    when User
      params.require(:user).permit(:domain, :disqus_shortname)
    end
  end
end
