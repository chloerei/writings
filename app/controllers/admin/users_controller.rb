class Admin::UsersController < Admin::BaseController
  def index
    @users = User.desc(:created_at).page(params[:page]).per(25)
  end

  def show
    @user = User.find_by :name => /\A#{params[:id]}\z/i
  end
end
