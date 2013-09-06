class Exporter::Base
  attr_accessor :space, :tmp_path, :output_path

  def initialize(space, options = {})
    self.space = space
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
    space.articles.untrash.asc(:created_at)
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
