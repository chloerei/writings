class Dashboard::AccountsController < Dashboard::BaseController
  def edit
  end

  def update
    if current_user.check_current_password(user_params[:current_password]) && current_user.update_attributes(user_params)
      respond_to do |format|
        format.json { render :json => current_user.as_json(:only => [:name, :email]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => current_user.errors.full_messages.join }, :status => 400}
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :domain, :disqus_shortname, :locale, :password, :password_confirmation, :current_password).delete_if { |key, value| value.empty? }
  end
end
