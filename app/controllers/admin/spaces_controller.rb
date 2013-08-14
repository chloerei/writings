class Admin::SpacesController < Admin::BaseController
  def index
    @spaces = Space.desc(:created_at).page(params[:page]).per(25)
  end

  def show
    @space = Space.find_by :name => params[:id]
  end
end
