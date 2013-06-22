class Exporter::Base
  attr_accessor :space, :category, :tmp_path, :output_path

  def initialize(space, options = {})
    self.space = space
    self.category = options[:category]
    time = Time.now.to_i
    self.tmp_path = options[:tmp_path] || "#{Rails.root}/tmp/exporters/#{time}"
    self.output_path = options[:output_path] || "#{Rails.root}/tmp/exporters_output/#{time}"
  end

  def prepare
    FileUtils.mkdir_p tmp_path
    FileUtils.mkdir_p output_path
  end

  def clean
    FileUtils.rm_r tmp_path, :force => true
  end

  def articles
    if category
      space.articles.where(:category_id => @category.id)
    else
      space.articles
    end.status(nil).includes(:category).asc(:created_at)
  end

  def helper
    ApplicationController.helpers
  end

  def url_helper
    Rails.application.routes.url_helpers
  end

  def clean_body(body)
    helper.article_format_body(helper.article_remove_h1(body))
  end
end
