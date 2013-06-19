class Dashboard::ImportTasksController < Dashboard::BaseController
  def index
  end

  def create
    @import_task = ImportTask.create import_task_param.merge(
      :user  => current_user,
      :space => @space
    )
    ImportTask.delay.perform_import(@import_task.id.to_s)
    redirect_to :action => :show, :id => @import_task
  end

  def show
  end

  private

  def import_task_param
    params.require(:import_task).permit(:format, :file)
  end
end
