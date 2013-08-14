class Admin::SpacesController < Admin::BaseController
  def index
    if params[:tab]
      @spaces = Space.desc(:created_at).in_plan(params[:tab]).page(params[:page]).per(25)
    else
      @spaces = Space.desc(:created_at).page(params[:page]).per(25)
    end
  end

  def show
    @space = Space.find_by :name => params[:id]
  end
end
