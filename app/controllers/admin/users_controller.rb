class Admin::UsersController < Admin::BaseController
  def index
    if params[:tab]
      @users = User.in_plan(params[:tab]).desc(:created_at).page(params[:page]).per(25)
    else
      @users = User.desc(:created_at).page(params[:page]).per(25)
    end
  end

  def show
    @user = User.find_by :name => /\A#{params[:id]}\z/i
  end
end
