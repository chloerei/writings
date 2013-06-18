class Exporter::Base
  def initialize(space, options = {})
    @space = space
    @category = options[:category]

    FileUtils.mkdir_p tmp_path
  end

  def tmp_path
    "#{Rails.root}/tmp/exporters/#{self.class.name.split('::').last.downcase}/#{@space.id}"
  end

  def articles
    if @category
      @space.articles.where(:category_id => @category.id)
    else
      @space.articles
    end.status(nil).includes(:category).asc(:created_at)
  end

  def helper
    ApplicationController.helpers
  end

  def url_helper
    Rails.application.routes.url_helpers
  end

  BUILD_TIMEOUT = 10
end
