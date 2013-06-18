class JekyllImporter < BaseImporter
  def import
    results = []

    Dir.chdir(tmp_path) do
      File.open('import.zip', 'wb') do |f|
        f.write @file.read
      end

      `unzip import.zip`

      Dir['_posts/*.{md,markdown}'].each do |filename|
        begin
          content = File.read filename
          title = nil
          status = 'draft'

          if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
            content = $'
            data = YAML.safe_load($1)

            title = data['title']
            if title
              content = "# #{title}\n\n" + content
            end
            status = (data['published'] == 'draft' ? 'draft' : 'publish')
          end

          _, date, urlname, _ = *filename.match(/\A_posts\/(\d+-\d+-\d+)-(.+)(\.[^.]+)\z/)
          created_at = Time.parse(date).utc rescue nil
          published_at = (status == 'publish' ? created_at : nil)
          urlname = filter_urlname(urlname)
          body = PandocRuby.convert(content, :from => :markdown, :to => :html)

          article = @space.articles.create!(
            :title        => title,
            :body         => body,
            :status       => status,
            :urlname      => urlname,
            :created_at   => created_at,
            :published_at => published_at
          )

          results << article
        rescue
        end
      end
    end

    results
  end
end
