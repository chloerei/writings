class JekyllExporter < BaseExporter
  def export
    Timeout::timeout(BUILD_TIMEOUT) do
      Dir.chdir(tmp_path) do
        FileUtils.mkdir_p '_posts'

        articles.includes(:category).each do |article|
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

        FileUtils.rm 'output.zip', :force => true
        `zip -r output.zip _posts`

        FileUtils.rm_r '_posts'
      end

      "#{tmp_path}/output.zip"
    end
  end
end
