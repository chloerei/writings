class Importer::Wordpress < Importer::Base
  def import
    Dir.chdir(tmp_path) do
      xml = Nokogiri::XML(file.read)

      xml.xpath('rss/channel/item').each do |item|
        begin
          title = item.xpath('title').text
          body = PandocRuby.convert(item.xpath('content:encoded').text, :from => :markdown, :to => :html)
          if title.present?
            body = "<h1>#{title}</h1>\n" + body
          end
          status = (item.xpath('wp:status').text == 'publishd' ? 'publish' : 'draft')
          urlname = item.xpath('wp:post_name').text
          created_at = Time.parse(item.xpath('wp:post_date')).utc rescue nil
          publishded_at = Time.parse(item.xpath('wp:pubDate')).utc rescue nil

          article = Article.new(
            :title => title,
            :body => body,
            :status => status,
            :urlname => urlname,
            :created_at => created_at,
            :publishded_at => publishded_at
          )

          yield article
        rescue
          # ignore
        end
      end
    end
  end
end
