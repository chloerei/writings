class Importer::Jekyll < Importer::Base
  def import
    File.open("#{tmp_path}/import.zip", 'wb') do |f|
      f.write file.read
    end

    `cd #{tmp_path} ; unzip import.zip`

    Dir["#{tmp_path}/_posts/*.{md,markdown}"].each do |filename|
      begin
        content = File.read filename
        title = nil
        status = 'draft'

        if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
          content = $'
          data = YAML.load($1, :safe => true)

          title = data['title']
          if title
            content = "# #{title}\n\n" + content
          end
          status = (!data['published'] ? 'draft' : 'publish')
        end

        _, date, urlname, _ = *filename.match(/\A#{tmp_path}\/_posts\/(\d+-\d+-\d+)-(.+)(\.[^.]+)\z/)
        created_at = Time.parse(date).utc rescue nil
        published_at = (status == 'publish' ? created_at : nil)
        body = PandocRuby.convert(content, :from => :markdown, :to => :html)

        article = ImportArticle.new(
          :title        => title,
          :body         => body,
          :status       => status,
          :urlname      => urlname,
          :created_at   => created_at,
          :published_at => published_at
        )

        yield article
      rescue => e
        # ignore on production
        raise e unless Rails.env.production?
      end
    end
  end
end
