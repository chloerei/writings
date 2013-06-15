class JekyllExporter
  def initialize(space, options = {})
    @space = space
    @category = options[:category]

    prepare
  end

  def tmp_path
    "#{Rails.root}/tmp/exporters/jekyll/#{@space.id}"
  end

  def prepare
    FileUtils.mkdir_p tmp_path
  end

  def articles
    if @category
      @space.articles.where(:category_id => @category.id)
    else
      @space.articles
    end
  end

  BUILD_TIMEOUT = 10

  def export
    Timeout::timeout(BUILD_TIMEOUT) do
      Dir.chdir(tmp_path) do
        FileUtils.mkdir_p '_posts'

        articles.includes(:category).each do |article|
          puts article.category_id
          name = article.urlname.present? ? "#{article.token}-#{article.urlname}" : article.token
          filename = "#{article.created_at.to_date.to_s}-#{name}.md"
          File.open("_posts/#{filename}", 'w') do |f|
            f.write "---\n"
            f.write "layout: post\n"
            f.write "title: #{article.title}\n"
            if article.category.present?
              f.write "category: #{article.category.name}\n"
            end
            f.write "published: #{article.publish?}\n"
            f.write "---\n\n"

            f.write PandocRuby.convert(article.body, { :from => :html, :to => 'markdown+hard_line_breaks' }, 'atx-headers')
          end
        end

        FileUtils.rm 'output.zip'
        `zip -r output.zip _posts`

        FileUtils.rm_r '_posts'
      end

      "#{tmp_path}/output.zip"
    end
  end
end
