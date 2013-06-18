class Dashboard::ExportTasksController < Dashboard::BaseController
  def index
  end

  def create
    if params[:range] == 'category'
      @category = @space.categories.where(:urlname => params[:category_id]).first
    end

    task = ExportTask.create(:space => @space, :category => @category, :format => params[:format])
    ExportTask.delay.perform_task(task.id.to_s)

    redirect_to :action => :show, :id => task
  end

  def show
    @export_task = @space.export_tasks.find params[:id]
  end

  def download
    @export_task = @space.export_tasks.where(:completed => true).find params[:id]
    send_file @export_task.path, :filename => @export_task.filename
  end
end
