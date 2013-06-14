class ArticleExporter
  def initialize(article)
    @article = article
    @doc = Nokogiri::HTML::DocumentFragment.parse(@article.body)

    prepare
  end

  def tmp_path
    "#{Rails.root}/tmp/exporters/article/#{@article.id}"
  end

  def prepare
    FileUtils.mkdir_p tmp_path
    FileUtils.mkdir_p "#{tmp_path}/images"
  end

  FETCH_THREAD_LIMIT = 10

  def fetch_images
    @doc.css('img').to_a.in_groups_of(FETCH_THREAD_LIMIT, false).each_with_index do |group, group_index|
      threads = []
      group.each_with_index do |img, index|
        begin
          url = URI(img['src'])
          local_path = "images/#{group_index * FETCH_THREAD_LIMIT + index}#{File.extname url.path}"
          img['src'] = local_path
          threads << Thread.new do
            system(*%W(curl -m 3 -s -o #{tmp_path}/#{local_path} #{url}))
          end
        rescue
        end
      end
      threads.each { |thread| thread.join(3) }
    end
  end

  def dump_body
    File.open("#{tmp_path}/body.html", 'w') do |f|
      f.write @doc.to_s
    end
  end

  def prepare_content
    fetch_images
    dump_body
  end

  def clean
    FileUtils.rmdir "#{tmp_path}/images"
  end

  BUILD_TIMEOUT = 10

  def build_md
    Timeout::timeout(BUILD_TIMEOUT) {
      dump_body
      `cd #{tmp_path} ; pandoc body.html -o output.md -t markdown+hard_line_breaks --atx-headers `
      clean
      "#{tmp_path}/output.md"
    }
  end

  def build_docx
    Timeout::timeout(BUILD_TIMEOUT) {
      prepare_content
      `cd #{tmp_path} ; pandoc body.html -o output.docx`
      clean
      "#{tmp_path}/output.docx"
    }
  end

  def build_odt
    Timeout::timeout(BUILD_TIMEOUT) {
      prepare_content
      `cd #{tmp_path} ; pandoc body.html -o output.odt`
      clean
      "#{tmp_path}/output.odt"
    }
  end
end
