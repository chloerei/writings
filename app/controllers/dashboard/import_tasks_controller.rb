class Dashboard::ImportTasksController < Dashboard::BaseController
  def index
  end

  def create
    @import_task = @space.import_tasks.create import_task_param.merge(:user => current_user)

    ImportTask.delay.perform_task(@import_task.id.to_s)
    redirect_to :action => :show, :id => @import_task
  end

  def show
    @import_task = @space.import_tasks.find params[:id]
  end

  def confirm
    @import_task = @space.import_tasks.where(:status => 'success').find params[:id]
    @import_task.confirm(params[:ids])
    @import_task.destroy
    redirect_to dashboard_root_path
  end

  private

  def import_task_param
    params.require(:import_task).permit(:format, :file)
  end
end
