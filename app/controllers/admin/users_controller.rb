class Admin::UsersController < Admin::BaseController
  def index
    if params[:tab]
      @users = User.where(:plan => params[:tab]).desc(:created_at).page(params[:page]).per(25)
    else
      @users = User.desc(:created_at).page(params[:page]).per(25)
    end
  end
end
