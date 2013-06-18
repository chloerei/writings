class Dashboard::ImportsController < Dashboard::BaseController
  def show
  end

  def create
    case params[:format]
    when 'jekyll'
      @results = Importer::Jekyll.new(@space, params[:file]).import
    when 'wordpress'
      @results = Importer::Wordpress.new(@space, params[:file]).import
    else
      redirect_to :action => :show
    end
  end
end
