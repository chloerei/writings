class SpacesController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'

  def new
  end

  def create
    @space = current_user.spaces.new space_params
    @space.save
  end

  private

  def space_params
    params.require(:space).permit(:name, :full_name, :description)
  end
end
