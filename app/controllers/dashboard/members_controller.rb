class Dashboard::MembersController < Dashboard::BaseController
  before_filter :require_workspace

  def index
  end
end
