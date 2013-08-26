class Dashboard::SettingsController < Dashboard::BaseController
  before_filter :require_creator

  def show
  end

  def update
    if @space.update_attributes space_params
      flash[:success] = t('update_success')
    end
  end

  private

  def space_params
    params.require(:space).permit(:name, :domain, :disqus_shortname, :full_name, :description, :gravatar_email, :google_analytics_id)
  end
end
