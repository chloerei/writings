class JekyllImporter < BaseImporter
  def import
    results = {}

    Dir.chdir(tmp_path) do
      File.open('import.zip', 'w') do |f|
        f.write @file.read
      end

      `unzip import.zip`

      Dir['_posts/*.{md,markdown}'].each do |filename|
        begin
          content = File.read filename

          if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
            content = $'
            data = YAML.safe_load($1)
          end

          title = data['title']
          content = "# #{title}\n\n" + content
          status = data['published'] == 'draft' ? 'draft' : 'publish'
          puts filename
          date, urlname, _ = *filename.match(/\A_posts\/(\d+-\d+-\d+)-(.+)(\.[^.]+)\z/)
          time = Time.parse(date)

          @space.articles.create!(
            :title => title,
            :body  => content,
            :status => status,
            :urlname => urlname,
            :created_at => time,
            :updated_at => Time.now,
            :published_at => (status == 'publish' ? time : nil)
          )

          results[title] = :success
        rescue
          results[title] = :error
        end
      end
    end

    results
  end
end
