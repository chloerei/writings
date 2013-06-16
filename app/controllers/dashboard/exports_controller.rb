class Dashboard::ExportsController < Dashboard::BaseController
  def show

  end

  def create
    if params[:range] == 'category'
      @category = @space.categories.where(:urlname => params[:category_id]).first
    end

    case params[:format]
    when 'jekyll'
      send_file JekyllExporter.new(@space, :category => @category).export, :filename => "#{@space.name}-jekyll-#{Time.now.to_s :number}.zip"
    when 'wordpress'
      send_file WordpressExporter.new(@space, :category => @category).export, :filename => "#{@space.name}-wordpress-#{Time.now.to_s :number}.xml"
    else
      redirect_to :action => :show
    end
  end
end
