class Exporter::Jekyll < Exporter::Base
  def export
    prepare

    FileUtils.mkdir_p "#{tmp_path}/_posts"

    articles.each do |article|
      name = article.urlname.present? ? "#{article.token}-#{article.urlname}" : article.token
      filename = "#{article.created_at.to_date.to_s}-#{name}.md"

      File.open("#{tmp_path}/_posts/#{filename}", 'w') do |f|
        f.write "---\n"
        f.write "layout: post\n"
        f.write "title: #{article.title}\n"
        f.write "published: #{article.publish?}\n"
        f.write "---\n\n"

        f.write PandocRuby.convert(clean_body(article.body), { :from => :html, :to => 'markdown+hard_line_breaks' }, 'atx-headers')
      end
    end

    FileUtils.rm "#{output_path}/jekyll.zip", :force => true
    `cd #{tmp_path} ; zip -r #{output_path}/jekyll.zip _posts`

    clean
  end
end
