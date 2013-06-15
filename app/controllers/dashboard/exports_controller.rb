class Dashboard::ExportsController < Dashboard::BaseController
  def show

  end

  def create
    if params[:range] == 'category'
      @category = @space.categories.where(:urlname => params[:category_id]).first
    end

    exporter_class = case params[:format]
               when 'jekyll'
                 JekyllExporter
               else
                 JekyllExporter
               end

    logger.info @category
    exporter = exporter_class.new(@space, :category => @category)
    logger.info exporter.articles.count

    send_file exporter.export, :filename => "#{@space.name}-#{Time.now.to_s :number}.zip"
  end
end
