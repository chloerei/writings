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
          time = Time.parse(date).utc

          article = @space.articles.create!(
            :title => title,
            :body  => PandocRuby.convert(content, :from => :markdown, :to => :html),
            :status => status,
            :urlname => @space.articles.where(:urlname => urlname).any? ? nil : urlname,
            :created_at => time,
            :updated_at => Time.now.utc,
            :published_at => (status == 'publish' ? time : nil)
          )

          results << article
        rescue
        end
      end
    end

    results
  end
end
