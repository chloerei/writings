class Dashboard::ExportsController < Dashboard::BaseController
  def show

  end

  def create
    if params[:range] == 'category'
      @category = @space.categories.where(:urlname => params[:category_id]).first
    end

    task = ExportTask.new(:space => @space, :category => @category, :format => params[:format])
    task.export

    send_file task.path, :filename => task.filename
  end
end
